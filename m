From: James Cameron <quozl-2X9k7bc8m7Mdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] mwifiex: add __GFP_REPEAT to skb allocation call
Date: Tue, 29 Mar 2016 16:31:03 +1100
Message-ID: <20160329053103.GH32709@us.netrek.org>
References: <1459226840-36287-1-git-send-email-wnhuang@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
	Nishant Sarmukadam <nishants-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>, snanda-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wei-Ning Huang <wnhuang-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1459226840-36287-1-git-send-email-wnhuang-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 29, 2016 at 12:47:20PM +0800, Wei-Ning Huang wrote:
> "single skb allocation failure" happens when system is under heavy
> memory pressure.  Add __GFP_REPEAT to skb allocation call so kernel
> attempts to reclaim pages and retry the allocation.

Oh, that's interesting, we're back to this symptom again.

Nice to see this fix.

Heavy memory pressure on 3.5 caused dev_alloc_skb failure in this
driver.  Tracked at OLPC as #12694.

-- 
James Cameron
http://quozl.netrek.org/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
