From: Ian Campbell <ian.campbell@citrix.com>
Subject: Re: [Xen-devel] [PATCH RFC] tcp: Allow sk_wmem_alloc to exceed
 sysctl_tcp_limit_output_bytes
Date: Wed, 15 Apr 2015 15:36:23 +0100
Message-ID: <1429108583.15516.304.camel@citrix.com>
References: <1427388414-31077-1-git-send-email-jonathan.davies@citrix.com>
	 <1427390070.25985.145.camel@edumazet-glaptop2.roam.corp.google.com>
	 <551555E3.80205@citrix.com> <552BC899.8090300@citrix.com>
	 <1428933925.3834.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <552BDAC6.2020708@citrix.com>
	 <CAFLBxZaDPa0Em6z-bwg1HoLqCU9R_rWD8ri+0sNVgX-Httj_1A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Malcolm Crossley <malcolm.crossley@citrix.com>,
	Jonathan Davies <jonathan.davies@citrix.com>,
	Wei Liu <Wei.Liu2@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev <netdev@vger.kernel.org>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>,
	David Vrabel <david.vrabel@citrix.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	xen-devel <xen-devel@lists.xenproject.org>,
	"Boris Ostrovsky" <boris.ostrovsky@oracle.com>,
	"David S. Miller" <davem@davemloft.net>
To: George Dunlap <George.Dunlap@eu.citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:28818 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752013AbbDOOgc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2015 10:36:32 -0400
In-Reply-To: <CAFLBxZaDPa0Em6z-bwg1HoLqCU9R_rWD8ri+0sNVgX-Httj_1A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-04-15 at 15:19 +0100, George Dunlap wrote:
> On Mon, Apr 13, 2015 at 4:03 PM, Malcolm Crossley
[...]
> > From a networking point of view, the backend is a switch. Is it OK to
> > consider the packet to have been transmitted from the guest point of
> > view once the backend is aware of the packet?
> >
> > This would help justify the skb_orphan() in the frontend.
> 
> This sounds sensible to me, particularly if virtio_net is already doing it.

I also find Malcolm's argument above pretty compelling.

Ian.
