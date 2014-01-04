From: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH man-pages] man: packet.7: document fanout, ring and auxiliary
 options
Date: Sun, 05 Jan 2014 00:10:42 +0100
Message-ID: <52C894F2.1060409@redhat.com>
References: <52A1F7D7.6040305@redhat.com> <1386350329-32723-1-git-send-email-willemb@google.com> <52A22B78.8070109@redhat.com> <52C81EF8.6090908@redhat.com> <CAKgNAkj8G6VvPLYF56884XcAWw+yOTUcF1UZSRwcYTk52D--zg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	linux-man <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAKgNAkj8G6VvPLYF56884XcAWw+yOTUcF1UZSRwcYTk52D--zg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 01/04/2014 10:57 PM, Michael Kerrisk (man-pages) wrote:
> Hello Daniel, and Willem,
>
> On Sun, Jan 5, 2014 at 3:47 AM, Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>> On 12/06/2013 08:54 PM, Daniel Borkmann wrote:
>>>
>>> On 12/06/2013 06:18 PM, Willem de Bruijn wrote:
>>>>
>>>> The packet socket manual page does not list all socket options.
>>>>
>>>> This patch adds descriptions of the common packet socket options
>>>>     PACKET_AUXDATA, PACKET_FANOUT, PACKET_RX_RING, PACKET_STATISTICS,
>>>>     PACKET_TX_RING
>>>>
>>>> and the ring-specific options
>>>>     PACKET_LOSS, PACKET_RESERVE, PACKET_TIMESTAMP, PACKET_VERSION
>>>>
>>>> It does not yet add descriptions for
>>>>     PACKET_COPY_THRESH, PACKET_HDRLEN, PACKET_ORIGDEV,
>>>>     PACKET_TX_HAS_OFF, PACKET_TX_TIMESTAMP, PACKET_VNET_HDR
>>>>
>>>> It tries to balance being informative with exposing kernel detail
>>>> that is unlikely to be used by most readers or that may change
>>>> frequently. For implementation details, the manpage points to the
>>>> documentation in kernel Documentation/networking. Let me know if
>>>> options should be added or removed.
>>>>
>>>> Source: PACKET_FANOUT, PACKET_RX_RING and PACKET_VERSION are in
>>>> /tools/testing/net/psock_fanout.c in the latest Linux kernel source
>>>> tree. PACKET_STATISTICS was in the first version of that test.
>>>> PACKET_TX_RING I have used elsewhere. The other options are based
>>>> on reading kernel code.
>>>>
>>>>    [Very minor fixups. -dborkman]
>>>>
>>>> Signed-off-by: Willem de Bruijn <willemb-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>>>
>>>
>>> Acked-by: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
>>>
>>> I went over the man page again, and it looks good to me.
>>>
>>> Great work and thanks for following up Willem!
>>
>>
>> Ping, Michael, any progress on this one? Lets not get this work
>> lost somewhere as it happened in March last year ...
>
> Thanks for the ping, and sorry for the delay. I've applied the patch:
> http://git.kernel.org/cgit/docs/man-pages/man-pages.git/commit/?id=dbb4f7516b22663da977ea5c37691c5940bb3eb7
>
> I added kernel version numbers for two of the newly documented
> options. You may want to check them:
> http://git.kernel.org/cgit/docs/man-pages/man-pages.git/commit/?id=342639d9e9d766b7b3b3a03045144be64f1f556c

Awesome, thanks Michael!

> Cheers,
>
> Michael
>
--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
