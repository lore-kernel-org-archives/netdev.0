From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next 07/12] vxlan: make vxlan_xmit_one void
Date: Tue, 11 Jun 2013 01:30:53 +0000 (UTC)
Message-ID: <kp5ukc$kja$1@ger.gmane.org>
References: <20130610200524.721617349@vyatta.com>
 <20130610132446.0783e4fb@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:41818 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754345Ab3FKBbN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jun 2013 21:31:13 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UmDQW-0000jR-RF
	for netdev@vger.kernel.org; Tue, 11 Jun 2013 03:31:12 +0200
Received: from 112.116.154.100 ([112.116.154.100])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 11 Jun 2013 03:31:12 +0200
Received: from xiyou.wangcong by 112.116.154.100 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 11 Jun 2013 03:31:12 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 Jun 2013 at 20:24 GMT, Stephen Hemminger <stephen@networkplumber.org> wrote:
>  		skb1 = skb_clone(skb, GFP_ATOMIC);
> -		if (skb1) {
> -			rc1 = vxlan_xmit_one(skb1, dev, rdst, did_rsc);
> -			if (rc == NETDEV_TX_OK)
> -				rc = rc1;
> -		}


None of your previous patches in _this_ patchset fixes the return value
of skb_clone(), therefore this patch can't be applied directly.


> +		if (skb1)
> +			vxlan_xmit_one(skb1, dev, rdst, did_rsc);


Thanks!
