From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pktgen: Allow setting frag sizes individually
Date: Tue, 01 Jul 2014 12:14:53 -0700 (PDT)
Message-ID: <20140701.121453.646524500364143878.davem@davemloft.net>
References: <1403728972-29548-1-git-send-email-zoltan.kiss@citrix.com>
	<1403728972-29548-3-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, minipli@googlemail.com,
	dborkman@redhat.com, tgraf@suug.ch, joe@perches.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	xen-devel@lists.xenproject.org
To: zoltan.kiss@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403728972-29548-3-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Wed, 25 Jun 2014 21:42:51 +0100

> By defining the number of frags via "nfrags", their sizes get calculated by
> pktgen. This patch allows their offsets and sizes to be specified via
> "frag_off-len", in a comma separated list (e.g.
> "frag_off-len 0-1,500-200,5000-10,9-100). The first is the offset
> (0 <= offset < 2^16), second is size (0 < length <= 65536). This also determines
> the number of frags, so it overwrites "frags" (and vice versa, "frags"
> invalidate this setting)
> xen-netback is prone to have problem with compound pages, as the memory granting
> interface can only handle 4k pages. This extension of pktgen is proven to be
> useful to test that.
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>

Can you respin these against current net-next and repost, thanks Zoltan.
