From: David Miller <davem@davemloft.net>
Subject: Re: BUG: ping without route segfaults in dst_release
Date: Mon, 28 Mar 2011 17:18:44 -0700 (PDT)
Message-ID: <20110328.171844.71116614.davem@davemloft.net>
References: <4D911758.3010608@pengutronix.de>
	<20110328.165149.193711805.davem@davemloft.net>
	<4D912538.8080001@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev@vger.kernel.org, kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <4D912538.8080001@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Tue, 29 Mar 2011 02:18:00 +0200

> On 03/29/2011 01:51 AM, David Miller wrote:
>> From: Marc Kleine-Budde <mkl@pengutronix.de>
>> Date: Tue, 29 Mar 2011 01:18:48 +0200
>> 
>>> root@ptx:~ ping 130.75.1.32
>>> PING 130.75.1.32 (130.75[   10.160000] Unable to handle kernel paging request at virtual address ffffffdb
>> 
>> Well, that was easy enough :-)
> 
> \o/, ping works again.
> 
>> --------------------
>> ipv4: Don't ip_rt_put() an error pointer in RAW sockets.
>> 
>> Reported-by: Marc Kleine-Budde <mkl@pengutronix.de>
>> Signed-off-by: David S. Miller <davem@davemloft.net>
> Tested-by: Marc Kleine-Budde <mkl@pengutronix.de>

Thanks for testing.
