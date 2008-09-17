From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [Bug #11500] /proc/net bug related to selinux
Date: Wed, 17 Sep 2008 15:32:49 -0700
Message-ID: <m17i9axv1q.fsf@frodo.ebiederm.org>
References: <j3zWxt-CgYL.A.WTF.bbsyIB@albercik>
	<1221483926.30816.18.camel@moss-spartans.epoch.ncsc.mil>
	<20080917125053.1f9ecf37.akpm@linux-foundation.org>
	<200809171724.36269.paul.moore@hp.com>
	<20080917144842.7df59f9e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Moore <paul.moore-VXdhtT5mjnY@public.gmane.org>, sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org,
	jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org, rjw-KKrjLPT3xs0@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080917144842.7df59f9e.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> (Andrew
	Morton's message of "Wed, 17 Sep 2008 14:48:42 -0700")
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> writes:

> We don't even know the extent of the damage yet.  Which distros were
> affected? With which versions of which userspace packages?

This seems to me to be an extremely fragile selinux user space policy.
In their code that derives security labels from path names.
Why don't we have AppArmor in the kernel again?

Further I don't see how we could have possibly have supported that user space
policy.  How can we apply a user space defined label required by the selinux
policy to a symlink that did not exist?

I expect cd /proc/self/net would work.  In your situation and you can
see /proc/self/net/dev.

Everything here sounds to me like that selinux policy is impossibly brittle.
And anything that is that brittle I have no intention in claiming is a bug
in proc.

Eric
