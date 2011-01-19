From: Justin Mattock <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/7] dma/shdma.c Typo change desciptor to descriptor.
Date: Wed, 19 Jan 2011 07:16:43 -0800
Message-ID: <FD016761-9581-4730-BC79-CBEFEB9ED3EC@gmail.com>
References: <1293817097-7945-1-git-send-email-justinmattock@gmail.com> <alpine.LNX.2.00.1101191537280.26685@pobox.suse.cz>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jiri Kosina <jkosina-AlSwsSmVLrQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.LNX.2.00.1101191537280.26685-ztGlSCb7Y1iN3ZZ/Hiejyg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On Jan 19, 2011, at 6:38 AM, Jiri Kosina wrote:

> On Fri, 31 Dec 2010, Justin P. Mattock wrote:
>
>> Below is a patch, that changes a typo from "desciptor" to  
>> "descriptor".
>> Let me know if I missed anything.
>>
>> Signed-off-by: Justin P. Mattock <justinmattock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>
>> ---
>> drivers/dma/shdma.c |    2 +-
>> 1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/dma/shdma.c b/drivers/dma/shdma.c
>> index 85ffd5e..72d25d9 100644
>> --- a/drivers/dma/shdma.c
>> +++ b/drivers/dma/shdma.c
>> @@ -740,7 +740,7 @@ static void sh_chan_xfer_ld_queue(struct  
>> sh_dmae_chan *sh_chan)
>> 		return;
>> 	}
>>
>> -	/* Find the first not transferred desciptor */
>> +	/* Find the first not transferred descriptor */
>> 	list_for_each_entry(desc, &sh_chan->ld_queue, node)
>> 		if (desc->mark == DESC_SUBMITTED) {
>> 			dev_dbg(sh_chan->dev, "Queue #%d to %d: %u@%x -> %x\n",
>
> I have folded the whole series into one patch and applied, thanks.
>
> -- 
> Jiri Kosina
> SUSE Labs, Novell Inc.



alright... I think there was one that needed adjusting, but given the  
situation Im in I wont be able to get to that
until other things in my life get sorted out.. Thanks for taking these

Justin P. Mattock
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
