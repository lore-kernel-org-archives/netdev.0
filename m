From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [NET] 64 bit byte counter for 2.6.3
Date: Thu, 19 Feb 2004 09:27:08 -0800
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20040219092708.1935e684@dell_ss3.pdx.osdl.net>
References: <20040218101711.25dda791@dell_ss3.pdx.osdl.net>
	<E1AtjKh-0006Bz-Ee@rhn.tartu-labor>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mroos@linux.ee, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: netdev@oss.sgi.com
In-Reply-To: <E1AtjKh-0006Bz-Ee@rhn.tartu-labor>
List-Id: netdev.vger.kernel.org

On Thu, 19 Feb 2004 10:14:55 +0200
Meelis Roos <mroos@linux.ee> wrote:

> SH>  * Network changes gets discussed on netdev@oss.sgi.com 
> SH>  * 64 bit values are not atomic on 32 bit architectures 
> 
> Agree.
> 
> SH>  * wider values in /proc output risks breaking apps like ifconfig and netstat
> 
> This is probably not a problem here, ifconfig etc have been working fine
> with non-wrapping numbers on sparc64 and other 64-bit machines.

Looking at current net-tools source, they are doing sscanf into a long-long-unsigned
value already.
