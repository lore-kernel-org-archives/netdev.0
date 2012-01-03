From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 01/11] SYSCTL: export root and set handling routines
Date: Mon, 02 Jan 2012 19:49:00 -0800
Message-ID: <m1vcotigyb.fsf@fess.ebiederm.org>
References: <20111214103602.3991.20990.stgit@localhost6.localdomain6>
	<20111214104449.3991.61989.stgit@localhost6.localdomain6>
	<m1bor6rg39.fsf@fess.ebiederm.org> <4EEEFC54.10700@parallels.com>
	<m18vm8g951.fsf@fess.ebiederm.org> <4EEF2C9A.8000403@parallels.com>
	<m1pqfkecw0.fsf@fess.ebiederm.org> <4EEF7364.8000407@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Trond.Myklebust\@netapp.com" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"linux-nfs\@vger.kernel.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Pavel Emelianov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"neilb\@suse.de" <neilb-l3A5Bk7waGM@public.gmane.org>,
	"netdev\@vger.kernel.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	James Bottomley <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"bfields\@fieldses.org" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	"davem\@davemloft.net" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"devel\@openvz.org" <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4EEF7364.8000407-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> (Stanislav Kinsbursky's message
	of "Mon, 19 Dec 2011 21:24:52 +0400")
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:

> 19.12.2011 20:37, Eric W. Biederman =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
>> Stanislav Kinsbursky<skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>  writes:
>>
>> Doing that independently of the rest of the sysctls is pretty horrib=
le
>> and confusing to users.   What I am planning might suit your needs a=
nd
>> if not we need to talk some more about how to get the vfs to do
>> something reasonable.
>>
>
> Ok, Eric. Would be glad to discuss your sysctls plans.
> But actually you already know my needs: I would like to make sysctls =
work in the
> way like sysfs does: i.e. content of files depends on mount maker -
> not viewer.

What drives the desire to have sysctls depend on the mount maker?
Especially what drives that desire not to have it have a /proc/<pid>/sy=
s
directory that reflects the sysctls for a given process.

Eric

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
