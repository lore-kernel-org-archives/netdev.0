From: Yang Bai <hamo.by-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] rtlwifi: get buffer_desc before trying to alloc new skb
Date: Fri, 13 Mar 2015 10:36:29 +0800
Message-ID: <CAO_0yfMgV7Sh8uJebE5VN4U3EkjCciYh659_OY5ZwJvjOgM7LA@mail.gmail.com>
References: <1426160036-1542-1-git-send-email-hamo.by@gmail.com> <5501CCFB.3040203@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5501CCFB.3040203-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 13, 2015 at 1:29 AM, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org> wrote:
> On 03/12/2015 06:33 AM, Yang Bai wrote:
>>
>> if rtlpriv->use_new_trx_flow == true and we run out of memory
>> to alloc a new skb, we will directly jump to no_new tag with
>> buffer_desc == NULL. Then we will dereference this NULL pointer
>> in function _rtl_pci_init_one_rxdesc.
>>
>> Signed-off-by: Yang Bai <hamo.by-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>
>
> Is the attached patch OK? I have tested it, but it is unlikely that I have
> hit any memory failures, thus that part needs to be checked by eye.

Looks good to me. Thanks very much for your review.

Yang
>
> Larry
>
>
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
