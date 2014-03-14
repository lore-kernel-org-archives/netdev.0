From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 2/2] net: Implement SO_PEERCGROUP
Date: Fri, 14 Mar 2014 16:54:18 -0700
Message-ID: <87k3bw1glx.fsf@xmission.com>
References: <1394657163-7472-1-git-send-email-vgoyal@redhat.com>
	<1394657163-7472-3-git-send-email-vgoyal@redhat.com>
	<5320CAEC.6030008@amacapital.net>
	<CALCETrUTjN=XKwnO62P9roZtLLuk7_9Oi17Mj_Aa2ZFtZc1gVA@mail.gmail.com>
	<1394658983.32465.203.camel@willson.li.ssimo.org>
	<CALCETrU29CpcK4dVRD45BGOD7AVEudADiFxOgFgKWkpFzw07eg@mail.gmail.com>
	<1394673476.32465.215.camel@willson.li.ssimo.org>
	<CALCETrWbCuKfV4zMkZajDOGhGkKduW0C2L7uHv=vtvqhVeAc6w@mail.gmail.com>
	<1394675038.32465.223.camel@willson.li.ssimo.org>
	<CALCETrV7GE0YL1sDDqTUV81rWL9zk2vTR1-VLkR7CfTA-FSrgw@mail.gmail.com>
	<20140313142755.GC18914@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Simo Sorce <ssorce-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"linux-kernel\@vger.kernel.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	jkaluza-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, lpoetter-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, kay-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140313142755.GC18914-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> (Vivek Goyal's message of
	"Thu, 13 Mar 2014 10:27:55 -0400")
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:

> On Wed, Mar 12, 2014 at 07:12:25PM -0700, Andy Lutomirski wrote:
>
>> I can think of at least three other ways to do this.
>> 
>> 1. Fix Docker to use user namespaces and use the uid of the requesting
>> process via SCM_CREDENTIALS.
>
> Using user namespaces sounds like the right way to do it (atleast
> conceptually). But I think hurdle here is that people are not convinced
> yet that user namespaces are secure and work well. IOW, some people
> don't seem to think that user namespaces are ready yet.

If the problem is user namespace immaturity patches or bug reports need
to be sent for user namespaces.

Containers with user namespaces (however immature they are) are much
more secure than running container with processes with uid == 0 inside
of them.  User namespaces do considerably reduce the attack surface of
what uid == 0 can do.

> I guess that's the reason people are looking for other ways to
> achieve their goal.

It seems strange to work around a feature that is 99% of the way to
solving their problem with more kernel patches.

Eric
