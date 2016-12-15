From: Tobias Klauser <tklauser@distanz.ch>
Subject: Re: [PATCH] net: ipv4: tcp_offload: check segs for NULL
Date: Thu, 15 Dec 2016 14:43:17 +0100
Message-ID: <20161215134315.GE5816@distanz.ch>
References: <1481791661-21670-1-git-send-email-shakya.das@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        shakya89.das@gmail.com, vidushi.koul@samsung.com
To: shakya.das@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sym2.noone.org ([178.63.92.236]:48269 "EHLO sym2.noone.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752067AbcLONnW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Dec 2016 08:43:22 -0500
Content-Disposition: inline
In-Reply-To: <1481791661-21670-1-git-send-email-shakya.das@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-12-15 at 09:47:41 +0100, shakya.das@samsung.com <shakya.das@samsung.com> wrote:
> From: Shakya Sundar Das <shakya.das@samsung.com>
> 
> This patch will check segs for being NULL in tcp_gso_segment()
> before calling skb_shinfo(segs) from skb_is_gso(segs), otherwise
> kernel can run into a NULL-pointer dereference.

How can segs ever be NULL here? skb_segment() will always either return
an skb or an ERR_PTR(err).
