From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [dccp] [RFC/RFT] [Patch 1/2]: Allow to distinguish original
	and retransmitted packets
Date: Thu, 5 Jun 2008 17:27:17 -0300
Message-ID: <20080605202716.GA6823@ghostprotocols.net>
References: <4846462F.3020004@cn.fujitsu.com> <20080604132152.GA17595@ghostprotocols.net> <20080604133849.GA5583@gerrit.erg.abdn.ac.uk> <20080604154452.GB4625@ghostprotocols.net> <20080604155540.GA16194@gerrit.erg.abdn.ac.uk> <20080605144435.GA8800@gerrit.erg.abdn.ac.uk> <20080605144529.GB8800@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>, netdev@vger.kernel.org,
	Wei Yongjun <yjwei@cn.fujitsu.com>, dccp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39633 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751274AbYFEU1a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2008 16:27:30 -0400
Content-Disposition: inline
In-Reply-To: <20080605144529.GB8800@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, Jun 05, 2008 at 03:45:29PM +0100, Gerrit Renker escreveu:
> dccp: Allow to distinguish original and retransmitted packets

Why not do it the way I suggested? I.e. using
__dccp_transmit_skb/dccp_transmit_skb? Less changes, same effect, or am
I missing something?

- Arnaldo
