From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: No sysfs directory for openvswitch module when built-in
Date: Tue, 5 Feb 2013 17:59:44 +0000
Message-ID: <1360087184.2857.2.camel@bwh-desktop.uk.solarflarecom.com>
References: <CAM_iQpVgEchb8UsxUP=w6OMbYx=zuP2yv=QwFhe8rPCbNBreVg@mail.gmail.com>
	 <87boc0liug.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jesse Gross <jesse@nicira.com>,
	"David S. Miller" <davem@davemloft.net>, Greg KH <greg@kroah.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:63826 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755041Ab3BER7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 12:59:48 -0500
In-Reply-To: <87boc0liug.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-02-04 at 16:29 +1030, Rusty Russell wrote:
> Cong Wang <xiyou.wangcong@gmail.com> writes:
> > Hello, Rusty, Jesse,
> >
> > I met an interesting problem when I compile openvswitch module as a
> > built-in (actually I compile ALL kernel modules as built-in), there is
> > no /sys/module/openvswitch/ directory created by the kernel in this
> > case.
> ...
> > What's worse, the user-space init script thinks openvswitch module is
> > not loaded by checking the exist of this directory, therefore refuses
> > to start.
> 
> We only know built-in "modules" exist if we see a parameter or version
> which mention them.  Looking for /sys/module/openvswitch/ is almost as
> flawed as looking in /proc/modules.
> 
> I hacked up something which lists KBUILD_MODNAME for every element in my
> kernel which did EXPORT_KERNEL or module_init, and most of them can
> never be modules, though any could have parameters.  Even if we changed
> the build system so we could tell things which "could have been a
> module", it's silly.
[...]

Isn't this information already provided by modules.builtin?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
