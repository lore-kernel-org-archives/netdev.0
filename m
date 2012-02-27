From: David Miller <davem@davemloft.net>
Subject: Re: RFC: memory leak in udp_table_init
Date: Mon, 27 Feb 2012 00:44:52 -0500 (EST)
Message-ID: <20120227.004452.1938112966101853526.davem@davemloft.net>
References: <1330147182.2462.25.camel@edumazet-laptop>
	<20120226.142038.556939530554716833.davem@davemloft.net>
	<1330321223.3330.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, tim.bird@am.sony.com,
	kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330321223.3330.1.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 27 Feb 2012 06:40:23 +0100

> It was to match the comment we have few lines above :
> 
> /*
>  * The pid hash table is scaled according to the amount of memory in the
>  * machine.  From a minimum of 16 slots up to 4096 slots at one gigabyte or
>  * more.
>  */

Granted, but that's not what the actual code did beforehand.

Please, make it a seperate change, thank you.
