From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] ip_gre: sendto/recvfrom NBMA address
Date: Tue, 23 Oct 2007 20:32:11 -0700 (PDT)
Message-ID: <20071023.203211.85412772.davem@davemloft.net>
References: <471E0638.9040405@trash.net>
	<471E19E5.5040509@iki.fi>
	<20071023190324.GA1267@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, kaber@trash.net, netdev@vger.kernel.org
To: kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60120
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755402AbXJXDc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 23:32:26 -0400
In-Reply-To: <20071023190324.GA1267@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Tue, 23 Oct 2007 23:03:24 +0400

> Hello!
> 
> > When GRE tunnel is in NBMA mode, this patch allows an application to use
> > a PF_PACKET socket to:
> > - send a packet to specific NBMA address with sendto()
> > - use recvfrom() to receive packet and check which NBMA address it came from
> > 
> > This is required to implement properly NHRP over GRE tunnel.
> 
> Ack. This is good idea.

Patch applied, thanks everyone!
