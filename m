From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2/2] r8169: RTL8169_registers clean-up
Date: Mon, 28 Feb 2005 21:30:17 -0500
Message-ID: <4223D3B9.8010604@pobox.com>
References: <20050228190444.GA13415@us.ibm.com> <20050228195958.GB8186@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jon Mason <jdmason@us.ibm.com>, netdev@oss.sgi.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050228195958.GB8186@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Jon Mason <jdmason@us.ibm.com> :
> 
>>An attempt to clean-up RTL8169_registers and  RTL8169_register_content.
>>Adjusted tab alignment and converted decimal values to hex.
>>
>>Applies cleanly to linux-2.6.11-rc4-mm1 and tested on amd64
> 
> 
> 1 - It does not use bitwise shifts where possible (suggested by Jeff);
> 2 - It is not consistent (see TxDesc...);
> 3 - Please write a script to reduce the patch and prove that a typo does
>     not hide somewhere (yep, I'm lazy). It would take too much testing
>     to get a complete coverage.

You can do a "diff -b" (ignore whitespaces changes) to check this sort 
of stuff.


> Jeff, how am I supposed to handle cleanups now ? Just say no ? :o)

Ideally keep a stack of patches such that, the fixes can be applied 
underneath the cleanups...

	Jeff
