From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] r8152: adjust rtl_start_rx
Date: Wed, 12 Nov 2014 22:31:46 -0500 (EST)
Message-ID: <20141112.223146.2221136950144767962.davem@davemloft.net>
References: <0835B3720019904CB8F7AA43166CEEB2ECE46C@RTITMBSV03.realtek.com.tw>
	<20141112.144949.645590790916569141.davem@davemloft.net>
	<0835B3720019904CB8F7AA43166CEEB2ECE8EF@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2ECE8EF@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Thu, 13 Nov 2014 02:31:14 +0000

> My last method which I mentioned yesterday is similar to
> this one. The difference is that I would re-use the rx
> buffers, so I have to add them to the list for re-submitting,
> not alwayes allocate new one.
> 
> Although one rx buffer could contain many packets, I don't
> think the whole size of the rx buffer is alwayes used.
> Therefore, I re-use the rx buffers to avoid allocating
> the 16K bytes rx buffer alwayes. This also makes sure that
> I always have the buffers to submit without allocating new
> one.
> 
> If you could accept this, I would modify this patch by
> this way.

I'll reread your original patch and think some more about this.

Thanks.
