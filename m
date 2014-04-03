From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: [PATCH regression] net: phy: fix initialization (config_init)
 for Marvel 88E1116R PHYs
Date: Thu, 03 Apr 2014 19:44:05 +0200
Message-ID: <533D9DE5.3000605@gmail.com>
References: <1396396559-6971-1-git-send-email-holler@ahsoftware.de> <CAGVrzcZd9tBtcTY_2PRHVb9kJAjVHqn+EubUy4NGL66M_UuCDg@mail.gmail.com> <533BD3CD.1010905@ahsoftware.de> <CAGVrzcZi5aNq8fR795fKhu2TAc1tQCa2YEorErZRLf2n9DPZuw@mail.gmail.com> <533C721E.1080004@gmail.com> <533C8B49.8080704@ahsoftware.de> <533C8ECB.4090900@gmail.com> <533D0B09.9040602@ahsoftware.de> <533D207E.9020909@gmail.com> <533D790C.5000104@ahsoftware.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Michal Simek <michal.simek@xilinx.com>,
	stable <stable@vger.kernel.org>
To: Alexander Holler <holler@ahsoftware.de>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <533D790C.5000104@ahsoftware.de>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/03/2014 05:06 PM, Alexander Holler wrote:
> Am 03.04.2014 10:49, schrieb Sebastian Hesselbarth:
>> On 04/03/2014 09:17 AM, Alexander Holler wrote:
>>> Am 03.04.2014 00:27, schrieb Sebastian Hesselbarth:
>>>> On 04/03/2014 12:12 AM, Alexander Holler wrote:
>>>>>> I am curious, how you determined above commit to be the cause of the
>>>>>> regression you are seeing. Can you bisect, if you didn't already?
>>>>>
>>>>> There was no bisecting necessary. I've just looked at what changed in
>>>>> mv643xx_eth since 3.13 and the first commit I've reverted was
>>>>> already a
>>>>> hit. Reading a bit source revealed the differences between the old
>>>>> reset
>>>>> and the newly used one and ended up with my patch (first try) and
>>>>> was a
>>>>> hit too.
>>>>
> 
> Sorry, continuing this discussion doesn't make sense. You have the same
> hw, so just try enabling netconsole with 3.14 and use dhcpcd from
> userland (this does the final reset here which hangs.
> 
> But don't suggest me (or insist on) a time consuming and totally useless
> bisect when I already know what makes the problem to appear (100%
> reliable here).

Alexander,

I tried to reproduce the regression on Dockstar with 3.14.0 and
3.14.0-07247-gcd6362be, netconsole enabled, DHCP (dhclient).

I can neither reproduce any issues with ethernet before nor after
dhclient kicks in. I can also use netconsole just fine and see
plenty of kernel bootlog messages sent to netconsole receiver.

Can you _please_ share a full report how to properly reproduce it?

Sebastian
