From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] r8152: adjust rtl_start_rx
Date: Tue, 11 Nov 2014 21:19:39 -0500 (EST)
Message-ID: <20141111.211939.1875418281655170486.davem@davemloft.net>
References: <1394712342-15778-90-Taiwan-albertk@realtek.com>
	<20141107.113522.837502028522211960.davem@davemloft.net>
	<0835B3720019904CB8F7AA43166CEEB2ECE337@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2ECE337@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Wed, 12 Nov 2014 01:45:08 +0000

> David Miller [mailto:davem@davemloft.net] 
>> Sent: Saturday, November 08, 2014 12:35 AM
> [...]
>> Does this even work?
>> 
>> If you leave a hole in the ring, the device is going to stop there
>> anyways.
>> 
>> So better to replenish the next time you call into this function
>> rather than leaving gaps in your receive ring.
> 
> Excuse me. Is this still unacceptable?
> Should I remove this patch for keeping the original flow?

I haven't had time to process your original reply, please be patient.
