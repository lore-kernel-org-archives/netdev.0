From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bne2 rx packet drop?
Date: Wed, 4 Aug 2010 16:47:03 -0700
Message-ID: <1280965623.7554.33.camel@HP1>
References: <201008050859.57659.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Rusty Russell" <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3197 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759509Ab0HDXsP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Aug 2010 19:48:15 -0400
In-Reply-To: <201008050859.57659.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 2010-08-04 at 16:29 -0700, Rusty Russell wrote:
> Hi Michael (and netdev!)
> 
>    I've got a customer seeing ~1000 rx packets dropped per day (on a busy
> interface, bonding) via 'netstat -ni' RX-DRP's field across their 4-node
> cluster.  The code seems to put checksum_discard and mac_discard into
> that counter, so I'm not sure what the root cause is.
> 
> Any hints?  What are the conditions which cause mac_discard?
> 

Please ask the customer for ethtool -S ethx.  It has a number of
different counters for rx dropped packets so we can get a better idea of
what's happening.

Thanks.


