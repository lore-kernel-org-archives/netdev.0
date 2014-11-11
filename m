From: Alexander Duyck <alexander.h.duyck-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [net-next PATCH v2 4/5] fm10k/igb/ixgbe: Replace __skb_alloc_page
 with netdev_alloc_page
Date: Tue, 11 Nov 2014 09:24:49 -0800
Message-ID: <54624661.4060905@redhat.com>
References: <20141111170711.15976.44062.stgit@ahduyck-vm-fedora20>	<20141111171117.15976.41609.stgit@ahduyck-vm-fedora20> <CAHA+R7P+GtA6xHxrPZOhxHM0LA8mGkmWugTqLeHtw5M6P3udvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	donald.c.skidmore-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org, balbi-l0cyMroinI0@public.gmane.org,
	matthew.vick-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, mgorman-l3A5Bk7waGM@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: Cong Wang <cwang-xCSkyg8dI+0RB7SZvlqPiA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAHA+R7P+GtA6xHxrPZOhxHM0LA8mGkmWugTqLeHtw5M6P3udvQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On 11/11/2014 09:15 AM, Cong Wang wrote:
> On Tue, Nov 11, 2014 at 9:11 AM, Alexander Duyck
> <alexander.h.duyck-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>> diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
>> index e645af4..73457ed 100644
>> --- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
>> +++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
>> @@ -83,7 +83,7 @@ static bool fm10k_alloc_mapped_page(struct fm10k_ring *rx_ring,
>>                  return true;
>>
>>          /* alloc new page for storage */
>> -       page = alloc_page(GFP_ATOMIC | __GFP_COLD);
>> +       page = dev_alloc_page();
> Doesn't match $subject.

Yeah, I just noticed that.  I missed the patch title and comments when I 
was doing the replacement.

v3 on the way.

Thanks,

Alex
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
