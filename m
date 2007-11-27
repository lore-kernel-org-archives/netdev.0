From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH] [NET]: Fix TX bug VLAN in VLAN
Date: Tue, 27 Nov 2007 14:32:49 +0900
Message-ID: <b25c3fa70711262132r3f88db02mcede6d14b82d5fc0@mail.gmail.com>
References: <003f01c82dca$305acd40$9c94fea9@jason>
	 <20071126112631.GA26599@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, tristan_schmelcher@alumni.uwaterloo.ca,
	acme@ghostprotocols.net
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.186]:64186 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431AbXK0Fcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2007 00:32:50 -0500
Received: by rv-out-0910.google.com with SMTP id k20so780761rvb
        for <netdev@vger.kernel.org>; Mon, 26 Nov 2007 21:32:49 -0800 (PST)
In-Reply-To: <20071126112631.GA26599@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2007/11/26, Herbert Xu <herbert@gondor.apana.org.au>:
> On Fri, Nov 23, 2007 at 12:12:52PM +0000, Joonwoo Park wrote:
> > This patch fixes http://bugzilla.kernel.org/show_bug.cgi?id=8766
> >
> > Is it possible?
> > BUG((veth->h_vlan_proto != htons(ETH_P_8021Q)) && !(VLAN_DEV_INFO(dev)->flags & VLAN_FLAG_REORDER_HDR))
> > I'm afraid, queued packet before vconfig set_flag would do that.
>
> Yes, AF_PACKET would do that.  So you should check both.
>

Thanks Herbert.
Well.. I think patch would work propely for AF_PACKET also.
(I did not insert BUG() macro in my patch)
How do you think?

Thanks
Joonwoo
