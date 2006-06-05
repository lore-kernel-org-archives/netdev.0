From: David Miller <davem@davemloft.net>
Subject: Re: MIB "ipInHdrErrors" error
Date: Mon, 05 Jun 2006 16:38:09 -0700 (PDT)
Message-ID: <20060605.163809.126578191.davem@davemloft.net>
References: <1148546261.3038.14.camel@RHEL3GM>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:5560
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750798AbWFEXiL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jun 2006 19:38:11 -0400
To: weid@nanjing-fnst.com
In-Reply-To: <1148546261.3038.14.camel@RHEL3GM>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Dong <weid@nanjing-fnst.com>
Date: Thu, 25 May 2006 16:37:42 +0800

>     When I test linux kernel 2.6.9-34, and find that kernel statistics
> about ipInHdrErrors which exsits in file /proc/net/snmp doesn't increase
> correctly.  The criteria conform to RFC2011:
> 
> ipInHdrErrors OBJECT-TYPE
>     SYNTAX      Counter32
>     MAX-ACCESS  read-only
>     STATUS      current
>     DESCRIPTION
>             "The number of input datagrams discarded due to errors in
>             their IP headers, including bad checksums, version number
>             mismatch, other format errors, time-to-live exceeded, errors
>             discovered in processing their IP options, etc."
> 
> When kernel receives an IP packet containing error protocol in IP
> header, kernel doesn't increase this counter "ipInHdrErrors".

This event is not listed in the description you quoted.

> Also, when kernel receives an IP packet and need to forward, but
> TTL=1 or TTL=0, kernel just sends an ICMP packet to inform the
> sender TTL count exceeded, and doesn't increase this counter.

This part of your change seems correct, please just resubmit
this part.
