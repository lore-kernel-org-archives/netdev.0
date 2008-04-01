From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [LLC]: skb allocation size for responses
Date: Mon, 31 Mar 2008 19:27:30 -0700 (PDT)
Message-ID: <20080331.192730.101669442.davem@davemloft.net>
References: <20080328131202.GP14945@ghostprotocols.net>
	<20080329060655.GA15023@tp64>
	<20080329120223.GZ14945@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joonwpark81@gmail.com, netdev@vger.kernel.org
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40941
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752074AbYDAC1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 22:27:30 -0400
In-Reply-To: <20080329120223.GZ14945@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Sat, 29 Mar 2008 09:02:23 -0300

> Perfect, thanks a lot:
> 
> Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Breaks the build:

net/llc/llc_sap.c: In function 'llc_mac_header_len':
net/llc/llc_sap.c:34: error: 'ARPHDR_IEEE802_TR' undeclared (first use in this function)
net/llc/llc_sap.c:34: error: (Each undeclared identifier is reported only once
net/llc/llc_sap.c:34: error: for each function it appears in.)
net/llc/llc_sap.c:35: error: invalid application of 'sizeof' to incomplete type 'struct thr_hdr' 
