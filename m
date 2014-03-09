From: David Miller <davem@davemloft.net>
Subject: Re: [BUG?] ixgbe: only num_online_cpus() of the tx queues are
 enabled
Date: Sun, 09 Mar 2014 18:31:54 -0400 (EDT)
Message-ID: <20140309.183154.1924955143324780850.davem@davemloft.net>
References: <1394336258.20149.80.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAG+wggY24+mc=8bCyr3fB+H7DJNfjANQuqbuDRcdUd9=+ip-Ew@mail.gmail.com>
	<1394372386.20149.88.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: v.mingchen@gmail.com, netdev@vger.kernel.org,
	ezk@fsl.cs.sunysb.edu, dhildeb@us.ibm.com, geoff@cs.hmc.edu
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36767 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbaCIWb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2014 18:31:56 -0400
In-Reply-To: <1394372386.20149.88.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 09 Mar 2014 06:39:46 -0700

> On Sun, 2014-03-09 at 01:47 -0500, Ming Chen wrote:
> 
>> Thanks for the patch. I forgot to mention that excessively big cwnd
>> (or bufferbloat) does play a part in Hash-Cast. We found that using
>> TCP Vegas does not show unfairness even in the presence of hash
>> collision among TCP flows. Comparing Vegas and Cubic, we found that
>> Vegas has a much smaller cwnd.
> 
> Of course, Vegas is delay based. It does not need to increase cwnd to
> insane values.
> 
> Problem is it does not compete well in presence of non Vegas flows.
> 
> And unfortunately, Internet is filled by non Vegas flows.

Vegas also does not respond quickly enough to sudden increases in
available bandwidth.
