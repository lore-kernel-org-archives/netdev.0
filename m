From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 7/10] net/mlx4_core: Use ARRAY_SIZE macro
Date: Tue, 05 Sep 2017 11:50:51 -0700 (PDT)
Message-ID: <20170905.115051.353243810279371029.davem@davemloft.net>
References: <1504439110050-939061377-0-diffsplit-thomas@m3y3r.de>
        <1504439110050-1961876957-7-diffsplit-thomas@m3y3r.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: thomas-VsYtu1Qij5c@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1504439110050-1961876957-7-diffsplit-thomas-VsYtu1Qij5c@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Thomas Meyer <thomas-VsYtu1Qij5c@public.gmane.org>
Date: Sun, 03 Sep 2017 14:19:31 +0200

> Use ARRAY_SIZE macro, rather than explicitly coding some variant of it
> yourself.
> Found with: find -type f -name "*.c" -o -name "*.h" | xargs perl -p -i -e
> 's/\bsizeof\s*\(\s*(\w+)\s*\)\s*\ /\s*sizeof\s*\(\s*\1\s*\[\s*0\s*\]\s*\)
> /ARRAY_SIZE(\1)/g' and manual check/verification.
> 
> Signed-off-by: Thomas Meyer <thomas-VsYtu1Qij5c@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
