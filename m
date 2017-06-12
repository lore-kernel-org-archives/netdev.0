From: "Baxter, Jim" <jim_baxter@mentor.com>
Subject: Re: [RFC V1 1/1] net: cdc_ncm: Reduce memory use when kernel memory
 low
Date: Mon, 12 Jun 2017 13:32:26 +0100
Message-ID: <7f2d3f89-7d87-f4ab-9799-559388602e76@mentor.com>
References: <04bc5b49-9282-a6ca-2b95-fb8fc9750555@mentor.com>
 <20170522.115426.1239443379414364630.davem@davemloft.net>
 <1495528968.2174.2.camel@suse.com>
 <20170523.112625.33559883707681029.davem@davemloft.net>
 <97db8a45-55ec-b68f-6f88-e934f67d31fc@mentor.com>
 <1497263047.15677.13.camel@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1497263047.15677.13.camel@suse.com>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Oliver Neukum (oneukum@suse.com) Sent: Mon, 12 Jun 2017 12:24:07 +0200

> Am Dienstag, den 23.05.2017, 20:06 +0100 schrieb Jim Baxter:
>> From: David S. Miller (davem@davemloft.net)
>> Sent: Tue, 23 May 2017 11:26:25 -0400 
>>>
>>> From: Oliver Neukum <oneukum@suse.com>
>>> Date: Tue, 23 May 2017 10:42:48 +0200
>>>
>>>>
>>>>
>>>> We could use a counter. After the first failure, do it once, after the
>>>> second twice and so on. And reset the counter as a higher order
>>>> allocation works. (just bound it somewhere)
>>>
>>> So an exponential backoff, that might work.
>>>
>>
>> As an idea I have created this patch as an addition to the original patch
>> in this series.
>>
>> Would this be acceptable?
>>
>> At the moment I have capped the value at 10, does anyone think it needs to
>> be much higher then that?
> 
> Hi,
> 
> I am working through mail backlog. If I may ask, has this patch proposal
> had a result or does something need to be done still?
> 
> 	Regards
> 		Oliver
> 
Hi,

I have not received any response to my additional patch yet.

Do you think I should submit it as a second RFC patchset?

Regards,
Jim
