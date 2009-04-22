From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] snmp: add missing counters for RFC 4293
Date: Wed, 22 Apr 2009 02:50:03 -0700 (PDT)
Message-ID: <20090422.025003.92631170.davem@davemloft.net>
References: <49EEA7E3.3080507@cosmosbay.com>
	<20090422.020837.58106317.davem@davemloft.net>
	<49EEE4F1.4020705@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48207
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751025AbZDVJuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 05:50:10 -0400
In-Reply-To: <49EEE4F1.4020705@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 22 Apr 2009 11:35:45 +0200

> So RFC4293 tells corresponding Octets variables should be supported :
> 
>  InOctets, InMcastOctets, OutMcastOctets, OutBcastOctets, OutOctets
> 
> And I dont see them in /proc/net/snmp or /proc/net/netstat
> 
> Mitsuru added :
> 
>        SNMP_MIB_ITEM("InNoRoutes", IPSTATS_MIB_INNOROUTES),
>        SNMP_MIB_ITEM("InTruncatedPkts", IPSTATS_MIB_INTRUNCATEDPKTS),
>        SNMP_MIB_ITEM("InMcastPkts", IPSTATS_MIB_INMCASTPKTS),
>        SNMP_MIB_ITEM("OutMcastPkts", IPSTATS_MIB_OUTMCASTPKTS),
>        SNMP_MIB_ITEM("InBcastPkts", IPSTATS_MIB_INBCASTPKTS),
>        SNMP_MIB_ITEM("OutBcastPkts", IPSTATS_MIB_OUTBCASTPKTS),
> 
> And Neil adds : InOctets, OutOctets, InMcastOctets and OutMcastOctets
> 
> Neil, you forgot OutBcastOctets :)

Fair enough.  Neil I wait for an updated patch :-)
