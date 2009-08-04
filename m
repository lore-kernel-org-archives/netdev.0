From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] NET: NETROM: Don't use static buffer.
Date: Tue, 04 Aug 2009 11:57:41 -0700 (PDT)
Message-ID: <20090804.115741.17537444.davem@davemloft.net>
References: <cover.1248620197.git.ralf@linux-mips.org>
	<65cb898f276a2dc3c56e6a78b5bc422303e6856f.1248620197.git.ralf@linux-mips.org>
	<20090726.190927.145496853.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org
To: ralf@linux-mips.org
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20090726.190927.145496853.davem@davemloft.net>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Sun, 26 Jul 2009 19:09:27 -0700 (PDT)

> From: Ralf Baechle <ralf@linux-mips.org>
> Date: Sat, 25 Jul 2009 11:38:17 +0100
> 
>> The use of a static buffer in nr_call_to_digi() to return its result is
>> not threadproof and can result in corruption if multiple threads are
>> trying to perform SIOCADDRT ioctls.
>> 
>> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> 
> So what frees up these now-dynamically-allocated digi objects?

Ralf, ping?
