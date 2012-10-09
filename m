From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: compound skb frag pages appearing in start_xmit
Date: Tue, 09 Oct 2012 16:27:27 +0200
Message-ID: <1349792847.21172.4479.camel@edumazet-glaptop>
References: <1349790467.21847.185.camel@zakaz.uk.xensource.com>
	 <1349790863.21172.4406.camel@edumazet-glaptop>
	 <1349792241.21847.199.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	xen-devel <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	Sander Eikelenboom <linux@eikelenboom.it>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:42929 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753703Ab2JIO1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 10:27:32 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so2687771bkc.19
        for <netdev@vger.kernel.org>; Tue, 09 Oct 2012 07:27:31 -0700 (PDT)
In-Reply-To: <1349792241.21847.199.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-09 at 15:17 +0100, Ian Campbell wrote:

> Does the higher order pages effectively reduce the number of frags which
> are in use? e.g if MAX_SKB_FRAGS is 16, then for order-0 pages you could
> have 64K worth of frag data.
> 
> If we switch to order-3 pages everywhere then can the skb contain 512K
> of data, or does the effective maximum number of frags in an skb reduce
> to 2?

effective number of frags reduce to 2 or 3

(We still limit GSO packets to ~63536 bytes)
