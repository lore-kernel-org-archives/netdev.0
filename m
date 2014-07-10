From: Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org>
Subject: Re: [PATCH v7 29/33] net: brcmfmac - set name assign type
Date: Thu, 10 Jul 2014 22:24:46 +0200
Message-ID: <CAG-2HqVnUwPpRwRwNpMXVN4zP4k3zUvJX5E4p-roi6BKpHTgNQ@mail.gmail.com>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
 <1404980258-30853-30-git-send-email-teg@jklm.no> <53BEF2A6.6050103@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	David Herrmann <dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kay Sievers <kay-tD+1rO4QERM@public.gmane.org>,
	Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Franky (Zhenhui) Lin" <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Hante Meuleman <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
To: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <53BEF2A6.6050103-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 10, 2014 at 10:08 PM, Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org> wrote:
> On 10-07-14 10:17, Tom Gundersen wrote:
>> The name is given by the firmware, so we assume it is predictable.
>
> How about the scenario where one would have multiple broadcom wifi
> devices in the system. Both driver instances would alloc_netdev with
> predictable but also the same ifname. Wondering whether we should ignore
> the firmware ifname altogether.

Hm, that would just fail irrespective of this patch, right? Sounds
like ignoring the firmware names is the right thing to do.

Cheers,

Tom
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
