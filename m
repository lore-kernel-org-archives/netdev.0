From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] snmp: add missing counters for RFC 4293
Date: Wed, 22 Apr 2009 06:53:09 -0400
Message-ID: <20090422105309.GB17947@hmsreliant.think-freely.org>
References: <49EEA7E3.3080507@cosmosbay.com> <20090422.020837.58106317.davem@davemloft.net> <49EEE4F1.4020705@cosmosbay.com> <20090422.025003.92631170.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dada1@cosmosbay.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60212 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752683AbZDVKxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 06:53:19 -0400
Content-Disposition: inline
In-Reply-To: <20090422.025003.92631170.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 22, 2009 at 02:50:03AM -0700, David Miller wrote:
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Wed, 22 Apr 2009 11:35:45 +0200
> 
> > So RFC4293 tells corresponding Octets variables should be supported :
> > 
> >  InOctets, InMcastOctets, OutMcastOctets, OutBcastOctets, OutOctets
> > 
> > And I dont see them in /proc/net/snmp or /proc/net/netstat
> > 
> > Mitsuru added :
> > 
> >        SNMP_MIB_ITEM("InNoRoutes", IPSTATS_MIB_INNOROUTES),
> >        SNMP_MIB_ITEM("InTruncatedPkts", IPSTATS_MIB_INTRUNCATEDPKTS),
> >        SNMP_MIB_ITEM("InMcastPkts", IPSTATS_MIB_INMCASTPKTS),
> >        SNMP_MIB_ITEM("OutMcastPkts", IPSTATS_MIB_OUTMCASTPKTS),
> >        SNMP_MIB_ITEM("InBcastPkts", IPSTATS_MIB_INBCASTPKTS),
> >        SNMP_MIB_ITEM("OutBcastPkts", IPSTATS_MIB_OUTBCASTPKTS),
> > 
> > And Neil adds : InOctets, OutOctets, InMcastOctets and OutMcastOctets
> > 
> > Neil, you forgot OutBcastOctets :)
> 
> Fair enough.  Neil I wait for an updated patch :-)
> 
Yep, you're right, thats the better spot for it, and I did miss the bcast
packets.  I'm not sure why people keep asking me to update snmp counters.  I'm
apparently very bad at it :). I'll repost soon

Neil

