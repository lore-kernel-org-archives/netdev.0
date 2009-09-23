From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: r8169, enabling TX checksumming breaks things?
Date: Wed, 23 Sep 2009 17:24:23 +0300
Message-ID: <200909231724.23132.denys@visp.net.lb>
References: <200909230915.27854.denys@visp.net.lb> <1253714544.3925.6.camel@lap75545.ornl.gov>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:54552 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751182AbZIWOVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 10:21:21 -0400
In-Reply-To: <1253714544.3925.6.camel@lap75545.ornl.gov>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 23 September 2009 17:02:24 David Dillow wrote:
> On Wed, 2009-09-23 at 09:15 +0300, Denys Fedoryschenko wrote:
> > Hi
> >
> > Is it expected that:
> > 1)TX checksumming is off by default
> > 2)If i try to enable it over ethtool -K eth0 tx on , TCP sessions on
> > proxy getting stuck, even in tcpdump looks everything fine and packets
> > reaching destination, i don't understand what is a reason of failure.
> > Maybe if this feature supposed to not work - user must not be able just
> > to turn it on?
>
> It is broken for large swaths of the hardware -- I have patches that got
> it and TSO working on my hardware, and they provide a framework to see
> about getting it working on yours.
>
> Basically, the fields are in different places depending on the chip
> revision. I'll try to dig those out tonight and send them along so we
> can experiment.
Thanks, i have 8 hosts (4 hosts with RTL8168b/8111b. and 4 with 
RTL8168d/8111d) to test. Ready for patches to test them :-)
