From: David Dillow <dave@thedillows.org>
Subject: Re: r8169, enabling TX checksumming breaks things?
Date: Wed, 23 Sep 2009 10:02:24 -0400
Message-ID: <1253714544.3925.6.camel@lap75545.ornl.gov>
References: <200909230915.27854.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emroute1.ornl.gov ([160.91.4.119]:37545 "EHLO emroute1.ornl.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753059AbZIWOCX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Sep 2009 10:02:23 -0400
Received: from emroute1.ornl.gov ([127.0.0.1])
 by emroute1.ornl.gov (PMDF V6.4 #31561)
 with ESMTP id <0KQF00LOZGC2UF@emroute1.ornl.gov> for netdev@vger.kernel.org;
 Wed, 23 Sep 2009 10:02:27 -0400 (EDT)
In-reply-to: <200909230915.27854.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-09-23 at 09:15 +0300, Denys Fedoryschenko wrote:
> Hi
> 
> Is it expected that:
> 1)TX checksumming is off by default
> 2)If i try to enable it over ethtool -K eth0 tx on , TCP sessions on proxy 
> getting stuck, even in tcpdump looks everything fine and packets reaching 
> destination, i don't understand what is a reason of failure.
> Maybe if this feature supposed to not work - user must not be able just to 
> turn it on?

It is broken for large swaths of the hardware -- I have patches that got
it and TSO working on my hardware, and they provide a framework to see
about getting it working on yours.

Basically, the fields are in different places depending on the chip
revision. I'll try to dig those out tonight and send them along so we
can experiment.
