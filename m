From: Hin-Tak Leung <hintak.leung-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 4/10]: rtl8187: Remove pointless check in rtl8187_rx_cb().
Date: Fri, 29 May 2009 16:41:20 +0100
Message-ID: <3ace41890905290841h427f8a27v8772cb34503247c2@mail.gmail.com>
References: <20090529.014011.244789664.davem@davemloft.net>
	 <20090529101834.GC3506@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090529101834.GC3506-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, May 29, 2009 at 11:18 AM, John W. Linville
<linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:
> On Fri, May 29, 2009 at 01:40:11AM -0700, David Miller wrote:
>>
>> First of all, it exposes the SKB list implementation.
>>
>> Second of all it's not needed.  If we get called here, we
>> successfully enqueued the URB with the linked SKB and
>> such a completion only gets called one time on such an
>> SKB.
>>
>> Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
>
> ACK

ACK.

I'll give this a try when I rebuild the rtl8187 module on my box.

Hin-Tak
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
