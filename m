From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [net-next-2.6 PATCH v2] allow access to sysfs_groups member
Date: Fri, 20 Nov 2009 08:32:48 -0800
Message-ID: <m1d43dtavj.fsf@fess.ebiederm.org>
References: <20091118164126.GF325@e-circ.dyndns.org>
	<20091118.095716.61189059.davem@davemloft.net>
	<20091118205952.GB282@e-circ.dyndns.org>
	<20091118.130859.99831401.davem@davemloft.net>
	<20091118214226.GA283@e-circ.dyndns.org>
	<m1vdh6t2y6.fsf@fess.ebiederm.org>
	<20091120102113.GC282@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Kurt Van Dijck <kurt.van.dijck@eia.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:58980 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752090AbZKTQcs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 11:32:48 -0500
In-Reply-To: <20091120102113.GC282@e-circ.dyndns.org> (Kurt Van Dijck's message of "Fri\, 20 Nov 2009 11\:21\:13 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kurt Van Dijck <kurt.van.dijck@eia.be> writes:

> On Thu, Nov 19, 2009 at 05:11:45PM -0800, Eric W. Biederman wrote:
>> Kurt Van Dijck <kurt.van.dijck@eia.be> writes:
>> 
>> > On Wed, Nov 18, 2009 at 01:08:59PM -0800, David Miller wrote:
>> >>
>> >> Unfortunately, the code in this function is much different
>> >> in net-next-2.6 which is where I want to add this, and your
>> >> patch doesn't apply.
>> >> 
>> >> Please rebase your patch on that tree, thank you.
>> > As I mentioned, I'm not experienced with using git yet.
>> > Is there a fine manual I can inspect? I get lost in the man-pages.
>> 
>> git clone git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git
>> 
>> Should get you started.
> $ git pull git://git.kernel.... master
> did the job today. It took me a while

An incremental  pull typically much faster than the initial one.

>> In this case please look at how I modified the bonding driver to do
>> what you are trying to do.  That is the conflict in net-next and
>> I think it was actually less code.

> It _is_ less code (does a little less too :-) ).
> It solves the problem anyway. I'll stop with my patch.

You were just worried about CAN devices and not all network devices
correct?

Eric
