From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [15/16] hostap: convert hostap_cmd_queue.usecnt from atomic_t to
 refcount_t
Date: Mon, 22 May 2017 15:24:55 +0000 (UTC)
Message-ID: <20170522152455.DF19960AEE@smtp.codeaurora.org>
References: <1490691403-4016-16-git-send-email-elena.reshetova@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-hams-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-ppp-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ganeshgr-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
        nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, blogic-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ajk-iz34hMvxm2Hmj42eshorlhS11BummzK+@public.gmane.org, paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org,
        j@w1.fi, peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
        gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
        Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Hans Liljestrand <ishkamiel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        David Windsor <dwindsor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1490691403-4016-16-git-send-email-elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> wrote:
> refcount_t type and corresponding API should be
> used instead of atomic_t when the variable is used as
> a reference counter. This allows to avoid accidental
> refcounter overflows that might lead to use-after-free
> situations.
> 
> Signed-off-by: Elena Reshetova <elena.reshetova-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Hans Liljestrand <ishkamiel-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> Signed-off-by: David Windsor <dwindsor-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

2 patches applied to wireless-drivers-next.git, thanks.

552aa585faff hostap: convert hostap_cmd_queue.usecnt from atomic_t to refcount_t
0aeffa7041d8 orinoco_usb: convert request_context.refcount from atomic_t to refcount_t

-- 
https://patchwork.kernel.org/patch/9648427/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
