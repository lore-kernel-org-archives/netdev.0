From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: skb->frag_list != NULL in start_xmit for device without
 NETIF_F_FRAGLIST
Date: Wed, 2 Mar 2011 13:14:43 +0000
Message-ID: <1299071683.17907.1764.camel@zakaz.uk.xensource.com>
References: <1298980019.5034.2238.camel@zakaz.uk.xensource.com>
	 <AANLkTinDmW1oirOFZCHe7yw8E8TGJfFe+fucAxOPpbjV@mail.gmail.com>
	 <1299071546.17907.1755.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Paul Durrant <Paul.Durrant@citrix.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:16177 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750956Ab1CBNOp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Mar 2011 08:14:45 -0500
In-Reply-To: <1299071546.17907.1755.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-03-02 at 13:12 +0000, Ian Campbell wrote:
> 
> > I believe that not much has changed in this regard between 2.6.32
> and net-next.
> 
> It turns out I cannot reproduce with either 2.6.32 (pvops xen.git) or
> a more recent ((26.38-rc) kernel. The kernel where we see this is the
> XCP kernel which is a 2.6.32 based thing derived from SLES11SP1 + XCP
> specific updates.

Paul reminded me that his XCP system where we see this is running
openvswitch not bridging (all my own tests were with bridging), is this
something which could be caused by vswitch at all? I don't see any
interesting ->frag_list usage in openvswitch.git.

Anyway I'm going to see if I can repro with vswitch.

Ian.

