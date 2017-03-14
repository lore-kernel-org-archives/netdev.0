From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH v2 2/2] can: spi: hi311x: Add Holt HI-311x CAN driver
Date: Tue, 14 Mar 2017 13:11:15 +0100
Message-ID: <eb4e0f6f-14de-3369-0d50-7371ae74f4fb@grandegger.com>
References: <1484680922-25813-1-git-send-email-akshay.bhat@timesys.com>
 <1484680922-25813-2-git-send-email-akshay.bhat@timesys.com>
 <234d9e75-0083-b8b4-c781-add653fdb550@grandegger.com>
 <b3ebb569-b50c-39ad-dec5-0059fbfba8fb@timesys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Akshay Bhat <nodeax-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Akshay Bhat <akshay.bhat-jEh4hwF5bVhBDgjK7y7TUQ@public.gmane.org>, mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <b3ebb569-b50c-39ad-dec5-0059fbfba8fb-jEh4hwF5bVhBDgjK7y7TUQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hallo Akshay,

Am 13.03.2017 um 16:38 schrieb Akshay Bhat:
> Hi Wolfgang,
>
> On 03/09/2017 12:36 PM, Wolfgang Grandegger wrote:
>> Hello,
>>
>> doing a quick review... I realized a few issues...
>>
>> Am 17.01.2017 um 20:22 schrieb Akshay Bhat:
... snip ...
>> A few other things to check:
>>
>> Run "cangen" and monitor the message with "candump -e any,0:0,#FFFFFFF".
>> Then 1) disconnect the cable or 2) short-circuit CAN low and high at the
>> connector. You should see error messages. After reconnection or removing
>> the short-circuit (and bus-off recovery) the state should go back to
>> "active".
>>
>
> With the above sequence, candump reports "ERRORFRAME" with
> protocol-violation{{}{acknowledge-slot}}, bus-error. On re-connecting
> the cable the can state goes back to ACTIVE and I see the messages that
> were in the queue being sent.

Do you get the ACK error also with berr-reporting off? Would be nice if 
you could show a candump log here.

Also, any error message should show the bus error counts in data[7,8]:

http://lxr.free-electrons.com/source/drivers/net/can/sja1000/sja1000.c#L408

And please check bus-off as well (short-circuiting CAN low and high).

Wolfgang.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
