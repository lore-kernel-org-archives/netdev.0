From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Need proper type casting before assignment, Remove
 compilation Warning.
Date: Sat, 09 Jul 2016 18:06:40 -0400 (EDT)
Message-ID: <20160709.180640.648031801699853376.davem@davemloft.net>
References: <1467916674-8418-1-git-send-email-arvind.yadav.cs@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leoli@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
To: arvind.yadav.cs@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1467916674-8418-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Date: Fri,  8 Jul 2016 00:07:54 +0530

> -Return type of 'qe_muram_alloc' is 'unsigned long', That Was trying to
> assigned in ucc_fast_tx_virtual_fifo_base_offset and
> ucc_fast_rx_virtual_fifo_base_offset. These variable are 'unsigned int'.
> So before assginment need a proper type casting.
> 
> -Passing value in IS_ERR_VALUE() is wrong, as they pass an 'int'
> into a function that takes an 'unsigned long' argument.This happens
> to work because the type is sign-extended on 64-bit architectures
> before it gets converted into an unsigned type.
> 
> -Passing an 'unsigned short' or 'unsigned int'argument into
> IS_ERR_VALUE() is guaranteed to be broken, as are 8-bit integers
> and types that are wider than 'unsigned long'.
> 
> -Any user will get compilation warning for that do not pass an
> unsigned long' argument.
> 
> Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>

Your subject line is improperly formed.

It must have the subsystem or driver name, followed by a colon ":"
and a space.  Such as:

	[PATCH] ucc_geth: Need proper type ...
