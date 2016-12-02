From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip6_offload: check segs for NULL in ipv6_gso_segment.
Date: Fri, 02 Dec 2016 13:36:36 -0500 (EST)
Message-ID: <20161202.133636.42467667676009914.davem@davemloft.net>
References: <1480597564-32355-1-git-send-email-asavkov@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jstancek@redhat.com, steffen.klassert@secunet.com,
        alexander.h.duyck@intel.com
To: asavkov@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480597564-32355-1-git-send-email-asavkov@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Artem Savkov <asavkov@redhat.com>
Date: Thu,  1 Dec 2016 14:06:04 +0100

> segs needs to be checked for being NULL in ipv6_gso_segment() before calling
> skb_shinfo(segs), otherwise kernel can run into a NULL-pointer dereference:
 ...
> Signed-off-by: Artem Savkov <asavkov@redhat.com>

Applied and queued up for -stable.
