From: Kurt Van Dijck <kurt.van.dijck@eia.be>
Subject: Re: [net-next-2.6 PATCH v2] allow access to sysfs_groups member
Date: Fri, 20 Nov 2009 11:21:13 +0100
Message-ID: <20091120102113.GC282@e-circ.dyndns.org>
References: <20091118164126.GF325@e-circ.dyndns.org> <20091118.095716.61189059.davem@davemloft.net> <20091118205952.GB282@e-circ.dyndns.org> <20091118.130859.99831401.davem@davemloft.net> <20091118214226.GA283@e-circ.dyndns.org> <m1vdh6t2y6.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay011.isp.belgacom.be ([195.238.6.178]:35458 "EHLO
	mailrelay011.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751910AbZKTKVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 05:21:09 -0500
Content-Disposition: inline
In-Reply-To: <m1vdh6t2y6.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 19, 2009 at 05:11:45PM -0800, Eric W. Biederman wrote:
> Kurt Van Dijck <kurt.van.dijck@eia.be> writes:
> 
> > On Wed, Nov 18, 2009 at 01:08:59PM -0800, David Miller wrote:
> >>
> >> Unfortunately, the code in this function is much different
> >> in net-next-2.6 which is where I want to add this, and your
> >> patch doesn't apply.
> >> 
> >> Please rebase your patch on that tree, thank you.
> > As I mentioned, I'm not experienced with using git yet.
> > Is there a fine manual I can inspect? I get lost in the man-pages.
> 
> git clone git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6.git
> 
> Should get you started.
$ git pull git://git.kernel.... master
did the job today. It took me a while
> 
> In this case please look at how I modified the bonding driver to do
> what you are trying to do.  That is the conflict in net-next and
> I think it was actually less code.
It _is_ less code (does a little less too :-) ).
It solves the problem anyway. I'll stop with my patch.

Thanks.
Kurt
