From: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: Re: [PATCH 01/11] SYSCTL: export root and set handling routines
Date: Tue, 10 Jan 2012 14:38:07 +0400
Message-ID: <4F0C150F.1020007@parallels.com>
References: <20111214103602.3991.20990.stgit@localhost6.localdomain6>	<20111214104449.3991.61989.stgit@localhost6.localdomain6>	<m1bor6rg39.fsf@fess.ebiederm.org> <4EEEFC54.10700@parallels.com>	<m18vm8g951.fsf@fess.ebiederm.org> <4EEF2C9A.8000403@parallels.com>	<m1pqfkecw0.fsf@fess.ebiederm.org> <4EEF7364.8000407@parallels.com> <m1vcotigyb.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Pavel Emelianov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"neilb-l3A5Bk7waGM@public.gmane.org" <neilb-l3A5Bk7waGM@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	James Bottomley <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <m1vcotigyb.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

03.01.2012 07:49, Eric W. Biederman =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> Stanislav Kinsbursky<skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>  writes:
>
>> 19.12.2011 20:37, Eric W. Biederman =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>>> Stanislav Kinsbursky<skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>   writes:
>>>
>>> Doing that independently of the rest of the sysctls is pretty horri=
ble
>>> and confusing to users.   What I am planning might suit your needs =
and
>>> if not we need to talk some more about how to get the vfs to do
>>> something reasonable.
>>>
>>
>> Ok, Eric. Would be glad to discuss your sysctls plans.
>> But actually you already know my needs: I would like to make sysctls=
 work in the
>> way like sysfs does: i.e. content of files depends on mount maker -
>> not viewer.
>
> What drives the desire to have sysctls depend on the mount maker?

Because we can (will, actually) have nested fs root's for containers. I=
OW,=20
container's root will be accessible from it's creator context. And I wa=
nt to=20
tune container's fs from creators context.

> Especially what drives that desire not to have it have a /proc/<pid>/=
sys
> directory that reflects the sysctls for a given process.
>

This is not so important for me, where to access sysctl's. But I'm worr=
ying=20
about backward compatibility. IOW, I'm afraid of changing path
"/proc/sys/sunprc/*" to "/proc/<pid>/sys/sunrpc". This would break a lo=
t of=20
user-space programs.

--=20
Best regards,
Stanislav Kinsbursky
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
