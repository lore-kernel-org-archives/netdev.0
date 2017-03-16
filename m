From: Akshay Bhat <akshay.bhat-jEh4hwF5bVhBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH v2 2/2] can: spi: hi311x: Add Holt HI-311x CAN driver
Date: Thu, 16 Mar 2017 13:06:55 -0400
Message-ID: <54d9a104-8ed1-4bb3-666e-042d3781dbfb@timesys.com>
References: <1484680922-25813-1-git-send-email-akshay.bhat@timesys.com>
 <1484680922-25813-2-git-send-email-akshay.bhat@timesys.com>
 <234d9e75-0083-b8b4-c781-add653fdb550@grandegger.com>
 <b3ebb569-b50c-39ad-dec5-0059fbfba8fb@timesys.com>
 <eb4e0f6f-14de-3369-0d50-7371ae74f4fb@grandegger.com>
 <3dbf8748-9d04-0f21-0e95-448d7a72e7d5@timesys.com>
 <41439729-42d0-d883-2801-2d3607f2aeab@grandegger.com>
 <CANiP4c8WMeT1Cr7WDXew1ne7DFR04oaA8Uch0zvyyOf5yCa37A@mail.gmail.com>
 <3dba0948-ffcb-8e80-fb32-62bb0aca6627@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
        Akshay Bhat <nodeax-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <3dba0948-ffcb-8e80-fb32-62bb0aca6627-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Wolfgang,

On 03/15/2017 05:42 AM, Wolfgang Grandegger wrote:
> Hello Akshay,
> 
..snip..
>>
>> So here is my plan:
>> - Have the bus error interrupt always enabled
>> - If berr-reporting off, then have the isr checks/reports state changes
> 
> Error state change messages should always be there. These are the
> important one.
> 
>> - if berr-reporting on, then have the isr checks/reports bus errors
>> and state changes (Does it make sense packing the error message, if
>> the ISR finds both bus and state changes?)
> 
> If berr-reporting is off, simply do not create an error message for bus
> errors, and only if the state changed. If it's "on" create an additional
> bus error message.
> 
> http://lxr.free-electrons.com/source/drivers/net/can/flexcan.c#L334
> 
> 

I have fixed the driver to handle the error reporting. Also thanks for
your tip for generating bus-off by setting the host device at a
different CAN bit rate! Below are logs with the updated driver. Let me
know if you have any concerns, if not I will submit the v4 patch.

berr-reporting on case:
http://pastebin.com/qDRLERmW

berr-reporting off case:
http://pastebin.com/fUn3j7qU

Thanks,
Akshay



--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
