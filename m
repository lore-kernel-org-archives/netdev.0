From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Keep kernel coding style rule of hfs-s+/sp source
Date: Wed, 01 Feb 2012 02:48:43 -0500 (EST)
Message-ID: <20120201.024843.318636456202840126.davem@davemloft.net>
References: <1328079593-19197-1-git-send-email-geunsik.lim@gmail.com>
	<20120201.020602.131240058939599710.davem@davemloft.net>
	<CAGFP0LKU0uDPQzhCy8qmThXQ9f9ofSnQrbr2dO83i+usc85_FQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, lucas.demarchi@profusion.mobi,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: geunsik.lim@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGFP0LKU0uDPQzhCy8qmThXQ9f9ofSnQrbr2dO83i+usc85_FQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geunsik Lim <geunsik.lim@gmail.com>
Date: Wed, 1 Feb 2012 16:45:09 +0900

> On Wed, Feb 1, 2012 at 4:06 PM, David Miller <davem@davemloft.net> wrote:
> 
>> From: Geunsik Lim <geunsik.lim@gmail.com>
>> Date: Wed,  1 Feb 2012 15:59:53 +0900
>>
>> > Modified for kernel coding style rule of hfs-s+/sp device driver .
>> > . reference: ./Documentation/CodingStyle
>> >
>> > ex)
>> > 60 Don't put multiple statements on a single line unless you have
>> > 61 something to hide:
>> > 62
>> > 63         if (condition) do_this;
>> > 64           do_something_everytime;
>> >
>> > Signed-off-by: Geunsik Lim <geunsik.lim@samsung.com>
>>
>> This was probably there to eliminate compiler warnings or avoid the
>>
> Thank you for your opinion.
> It's strange. I did not meet compiler warnings you replied.
> What is the version of GCC that You tried to compile Linux kernel source
> in your experience?

I'm saying the code was likely written this way "because" of that
reason, I didn't say I saw such a warning.  Where did I say I saw
the warning in question?

I stated a very likely reason why the original code was written the
way that it was.

>> code being eliminated completely, because the result of the register
>> read is unused.
>>
> Are you mean that the result of the register read is used if we append
> "if statement" of c language?

I was saying that without some kind of use of the interface's return
value, without some other control such as a volatile asm statement or
a reference to a volatile memory location, the compiler might legally
be able to remove the I/O register read completely.

You need to make sure that the assembler code does not change due to
your changes, and in particular these I/O register read calls do not
get eliminated.
