From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][TG3]Some cleanups
Date: Wed, 03 Oct 2007 09:18:47 -0400
Message-ID: <1191417527.4357.25.camel@localhost>
References: <1191175890.6165.17.camel@localhost>
	 <1191284504.25892.129.camel@dell> <1191328627.4353.15.camel@localhost>
	 <1191368033.5961.22.camel@dell>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Matt Carlson <mcarlson@broadcom.com>,
	netdev <netdev@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.239]:1377 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752954AbXJCNSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 09:18:51 -0400
Received: by nz-out-0506.google.com with SMTP id s18so3252602nze
        for <netdev@vger.kernel.org>; Wed, 03 Oct 2007 06:18:50 -0700 (PDT)
In-Reply-To: <1191368033.5961.22.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-02-10 at 16:33 -0700, Michael Chan wrote:

> Seems ok to me.  I think we should make it more clear that we're
> skipping over the VLAN tag:
> 
> (struct tg3_tx_cbdata *)&((__skb)->cb[sizeof(struct vlan_skb_tx_cookie)])
> 

Will do - thanks Michael.

cheers,
jamal

