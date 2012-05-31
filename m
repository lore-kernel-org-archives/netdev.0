From: Hal Rosenstock <hal-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH 1/25 v2] rdma/cm: define native IB address
Date: Thu, 31 May 2012 11:53:51 -0400
Message-ID: <4FC7940F.5010309@dev.mellanox.co.il>
References: <1828884A29C6694DAF28B7E6B8A8237325661ADD@ORSMSX102.amr.corp.intel.com> <CAL1RGDUu9sUbeWgBwivnAeXf+OWX_m5MRrizfzP4ni-FOGxiTQ@mail.gmail.com> <1828884A29C6694DAF28B7E6B8A82373374F1A64@ORSMSX102.amr.corp.intel.com> <CAL1RGDV-oYkNwQQUkAuUEHTH=HbmLk6Kv7JRnJ3XxN1DMNzLNQ@mail.gmail.com> <1828884A29C6694DAF28B7E6B8A823733B7669D7@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-rdma (linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org)"
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1828884A29C6694DAF28B7E6B8A823733B7669D7-P5GAC/sN6hmkrb+BlOpmy7fspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 3/7/2012 12:45 PM, Hefty, Sean wrote:
>> On Mon, Feb 27, 2012 at 2:22 PM, Hefty, Sean <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> wrote:
>>>>> --- a/include/linux/socket.h
>>>>> +++ b/include/linux/socket.h
>>>>> @@ -184,6 +184,7 @@ struct ucred {
>>>>>  #define AF_PPPOX       24      /* PPPoX sockets                */
>>>>>  #define AF_WANPIPE     25      /* Wanpipe API Sockets */
>>>>>  #define AF_LLC         26      /* Linux LLC                    */
>>>>> +#define AF_IB          27      /* Native InfiniBand address    */
>>>>>  #define AF_CAN         29      /* Controller Area Network      */
>>>>>  #define AF_TIPC                30      /* TIPC
>> sockets                 */
>>>>>  #define AF_BLUETOOTH   31      /* Bluetooth sockets            */
>>>>> @@ -227,6 +228,7 @@ struct ucred {
>>>>>  #define PF_PPPOX       AF_PPPOX
>>>>>  #define PF_WANPIPE     AF_WANPIPE
>>>>>  #define PF_LLC         AF_LLC
>>>>> +#define PF_IB          AF_IB
>>>>>  #define PF_CAN         AF_CAN
>>>>>  #define PF_TIPC                AF_TIPC
>>>>>  #define PF_BLUETOOTH   AF_BLUETOOTH
>>>>
>>>> Has this been run by the networking community?  Are they OK with this
>>>> assignment?
>>>
>>> I did copy netdev on the original submissions, but I don't remember any
>> explicit ack or nack.
>>
>> David, any feeling yay or nay about adding these?
>>
>> Is the kernel the final arbiter of AF_xxx / PF_xxx assignments, or
>> is there anything else we have to worry about?
> 
> To clarify the intent of this change:
> 
> The RDMA CM allows users to specify addresses using struct sockaddr.  Today, only INET/6 are supported.  
> The intent is to allow a user to specify native InfiniBand addresses through that interface.  
> In the more immediate, this helps to solve InfiniBand scaling issues.

Yes, this is key for InfiniBand scaling.

> Longer term, this can also be used to control path failover.

This AF_IB patch series appears to be stalled unless I missed something
on the list. What needs to be done to revive it/move it along ?

Thanks.

-- Hal

> 
> - Sean
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
