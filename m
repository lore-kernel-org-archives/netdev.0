From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 2/2] CDC_NCM: adding support FLAG_NOARP for Infineon
 modem platform
Date: Sun, 20 Jan 2013 23:09:02 -0500 (EST)
Message-ID: <20130120.230902.1326170122198671921.davem@davemloft.net>
References: <1358662329-8294-2-git-send-email-cpuwolf@gmail.com>
	<50FC25B7.70708@mvista.com>
	<CACa7zynymtYN4OtTjVNTNdB23eNU4D-G+JqaTxjaPFekRHkRAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sshtylyov-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org, dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, peter-Y+HMSxxDrH8@public.gmane.org,
	oneukum-l3A5Bk7waGM@public.gmane.org, gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org,
	alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org, bjorn-yOkvZcmFvRU@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: cpuwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACa7zynymtYN4OtTjVNTNdB23eNU4D-G+JqaTxjaPFekRHkRAg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Wei Shuai <cpuwolf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Mon, 21 Jan 2013 10:20:22 +0800

> The main problem is that these devices don't support ethernet.

He's saying your comment is referring to the wrong thing,
rather than saying anything against what your change is
doing.

Read his feedback carefully:

>>> +/* Same as wwan_info, but with IFF_NOARP  */
>>
>>     FLAG_NOARP, you mean?

He's saying your commnet is talking about FLAG_NOARP rather
than what the core code does with this flag, which is
translate into setting IFF_NOARP on the net device.

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
