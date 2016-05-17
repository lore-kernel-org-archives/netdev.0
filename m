From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: Fix coding style warnings and errors.
Date: Tue, 17 May 2016 11:35:08 -0400 (EDT)
Message-ID: <20160517.113508.276162469969907777.davem@davemloft.net>
References: <1463454990-9723-1-git-send-email-amitg.b14@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: amitg.b14@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463454990-9723-1-git-send-email-amitg.b14@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amit Ghadge <amitg.b14@gmail.com>
Date: Tue, 17 May 2016 08:46:30 +0530

> Clean up checkpatch warnings and errors:
> 
> * WARNING: Block comments use * on subsequent lines
> * WARNING: Missing a blank line after declarations
> * WARNING: networking block comments don't use an empty /* line, use /*
> * ERROR: code indent should use tabs where possible
> * WARNING: please, no space before tabs
> * WARNING: please, no spaces at the start of a line
> * WARNING: line over 80 characters
> * ERROR: space prohibited after that open parenthesis '('
> 
> Signed-off-by: Amit Ghadge <amitg.b14@gmail.com>

I hate robotic checkpatch fixes like this.

> @@ -58,8 +59,7 @@ static int __init probe_list2(int unit, struct devprobe2 *p, int autoprobe)
>  	return -ENODEV;
>  }
>  
> -/*
> - * ISA probes that touch addresses < 0x400 (including those that also
> +/*ISA probes that touch addresses < 0x400 (including those that also
>   * look for EISA/PCI cards in addition to ISA cards).
>   */

You're making the comment look worse not better, because you don't even
have a space between the "/*" and "ISA".

Honestly, does that look nice when you look at it?

If you're not going to put thought and serious consideration into this
change, don't do it at all, thank you.
