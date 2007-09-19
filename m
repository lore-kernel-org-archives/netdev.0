From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: bnx2 dirver's firmware images
Date: Wed, 19 Sep 2007 09:40:14 -0400
Message-ID: <46F126BE.5060507@tmr.com>
References: <1190141114.9540.216.camel@dell>	<20070918.112337.74737433.davem@davemloft.net>	<1190145951.9540.230.camel@dell> <20070918.122150.124083496.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, vda.linux@googlemail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759716AbXISNgr@vger.kernel.org>
In-Reply-To: <20070918.122150.124083496.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: "Michael Chan" <mchan@broadcom.com>
> Date: Tue, 18 Sep 2007 13:05:51 -0700
> 
>> The bnx2 firmware changes quite frequently.  A new driver quite often
>> requires new firmware to work correctly.  Splitting them up makes things
>> difficult for the user.
>>
>> The firmware in tg3 is a lot more mature and I don't expect it to
>> change.  I think tg3 is better suited for using request_firmware().
> 
> Like I said, I think neither should change and the driver should
> be fully functional when built statically into the kernel.
> 
Is that a suggestion that the driver work differently when built as a 
module or built in? I've seen that behavior many time over the years, 
but it usually not deliberate. ;-)

-- 
Bill Davidsen <davidsen@tmr.com>
   "We have more to fear from the bungling of the incompetent than from
the machinations of the wicked."  - from Slashdot
