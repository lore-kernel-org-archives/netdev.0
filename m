From: Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org>
Subject: Re: [PATCH v7 29/33] net: brcmfmac - set name assign type
Date: Tue, 15 Jul 2014 21:57:36 +0200
Message-ID: <CAG-2HqW53FvH5HnqfwtHqbYYROhTE0o4sN+=zzt=hindVxVuRA@mail.gmail.com>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
 <1404980258-30853-30-git-send-email-teg@jklm.no> <20140715193926.GF26012@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	David Herrmann <dh.herrmann-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Kay Sievers <kay-tD+1rO4QERM@public.gmane.org>,
	Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Franky (Zhenhui) Lin" <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Hante Meuleman <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140715193926.GF26012-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 15, 2014 at 9:39 PM, John W. Linville
<linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:
> I don't seem to have a line with "NET_NAME_UNKNOWN" in this driver
> in any of my kernel trees.  What tree are you using for development?

This was patch part of the series introducing NET_NAME_UNKNOWN [0].
I'll resubmit this patch once the earlier patches introducing the
infrastructure have been applied.

Cheers,

Tom

[0]: <https://lkml.org/lkml/2014/7/10/94>.

> On Thu, Jul 10, 2014 at 10:17:34AM +0200, Tom Gundersen wrote:
>> The name is given by the firmware, so we assume it is predictable.
>>
>> Signed-off-by: Tom Gundersen <teg-B22kvLQNl6c@public.gmane.org>
>> Cc: Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
>> Cc: Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
>> Cc: "Franky (Zhenhui) Lin" <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
>> Cc: Hante Meuleman <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
>> Cc: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
>> Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> Cc: brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org
>> ---
>>  drivers/net/wireless/brcm80211/brcmfmac/fweh.c | 3 ++-
>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/wireless/brcm80211/brcmfmac/fweh.c b/drivers/net/wireless/brcm80211/brcmfmac/fweh.c
>> index f6990f2..8d32721 100644
>> --- a/drivers/net/wireless/brcm80211/brcmfmac/fweh.c
>> +++ b/drivers/net/wireless/brcm80211/brcmfmac/fweh.c
>> @@ -201,7 +201,8 @@ static void brcmf_fweh_handle_if_event(struct brcmf_pub *drvr,
>>               brcmf_dbg(EVENT, "adding %s (%pM)\n", emsg->ifname,
>>                         emsg->addr);
>>               ifp = brcmf_add_if(drvr, ifevent->bssidx, ifevent->ifidx,
>> -                                emsg->ifname, NET_NAME_UNKNOWN, emsg->addr);
>> +                                emsg->ifname, NET_NAME_PREDICTABLE,
>> +                                emsg->addr);
>>               if (IS_ERR(ifp))
>>                       return;
>>               brcmf_fws_add_interface(ifp);
>> --
>> 1.9.3
>>
>>
>
> --
> John W. Linville                Someday the world will need a hero, and you
> linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org                  might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
