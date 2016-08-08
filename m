From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [ovs-dev] [PATCH net-next v11 5/6] openvswitch: add layer 3
 flow/port support
Date: Mon, 8 Aug 2016 17:28:39 +0200
Message-ID: <20160808172839.2cc42c61@griffin>
References: <1467827996-32547-1-git-send-email-simon.horman@netronome.com>
	<1467827996-32547-6-git-send-email-simon.horman@netronome.com>
	<CAOrHB_BYD40ZkWbU0dvhPOCcaCVgooksOUkejxyFoagyoiBTNw@mail.gmail.com>
	<20160713073152.GC29661@penelope.isobedori.kobe.vergenet.net>
	<CAOrHB_A1ri6fouFH0H4KpEqg1icCmz+U1tcgn-5BoryX5pb1gw@mail.gmail.com>
	<20160718045025.GA2490@penelope.isobedori.kobe.vergenet.net>
	<CAOrHB_C3Hq-V4uPWLELSc2VMywjYSnKiFJ4VJQDnPpCu7s1Xkw@mail.gmail.com>
	<20160720000243.GA4688@penelope.isobedori.kobe.vergenet.net>
	<CAOrHB_CUPCfAPKfoco9GghiAZ=QyEqxpd90uo3NvEtG9STXMVA@mail.gmail.com>
	<20160808151716.GA8477@penelope.isobedori.kobe.vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: pravin shelar <pshelar@ovn.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	ovs dev <dev@openvswitch.org>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54928 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752020AbcHHP2n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Aug 2016 11:28:43 -0400
In-Reply-To: <20160808151716.GA8477@penelope.isobedori.kobe.vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 8 Aug 2016 17:17:17 +0200, Simon Horman wrote:
> +bool skb_mac_header_present(struct sk_buff *skb)
> +{
> +	return skb->dev->type == ARPHRD_ETHER ||
> +		(skb->dev->type == ARPHRD_NONE &&
> +		 skb->protocol == htons(ETH_P_TEB));
> +}
> +EXPORT_SYMBOL(skb_mac_header_present);

I'd suggest a different name, this looks like it has something to do
with skb->mac_header, which it doesn't. skb_eth_header_present, perhaps?

 Jiri
