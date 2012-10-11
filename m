From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [Xen-devel] compound skb frag pages appearing in start_xmit
Date: Thu, 11 Oct 2012 11:14:54 +0100
Message-ID: <1349950494.14806.29.camel@zakaz.uk.xensource.com>
References: <1349790467.21847.185.camel@zakaz.uk.xensource.com>
	 <1349790863.21172.4406.camel@edumazet-glaptop>
	 <1349792241.21847.199.camel@zakaz.uk.xensource.com>
	 <1349792847.21172.4479.camel@edumazet-glaptop>
	 <1349793630.21847.208.camel@zakaz.uk.xensource.com>
	 <1349863984.10070.26.camel@zakaz.uk.xensource.com>
	 <1349874598.10070.39.camel@zakaz.uk.xensource.com>
	 <748966751.20121010164949@eikelenboom.it>
	 <1349942546.14806.7.camel@zakaz.uk.xensource.com>
	 <151954917.20121011120004@eikelenboom.it>
	 <1349949924.21172.8462.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sander Eikelenboom <linux@eikelenboom.it>,
	xen-devel <xen-devel@lists.xen.org>,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:50453 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758305Ab2JKKPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 06:15:16 -0400
In-Reply-To: <1349949924.21172.8462.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-11 at 11:05 +0100, Eric Dumazet wrote:
> On Thu, 2012-10-11 at 12:00 +0200, Sander Eikelenboom wrote:
> 
> > Probably due to the BUG_ON from the patch below, i changed it into a WARN_ON.
> > And i seem to hit it, but only in one of the guests at the moment and it triggers quite irregularly.
> 
> xennet_make_frags() is able to split the skb->head in multiple page-size
> chunks.
> 
> It should do the same for fragments

Right, I just want to be reproduce the issue so I can know I've fixed it
properly ;-)

Ian.
