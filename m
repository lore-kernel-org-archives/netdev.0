From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: Re: [PATCH 19/20] drivers/net/ethernet/marvell/skge.c: fix error
 return code
Date: Thu, 4 Oct 2012 20:49:57 +0200
Message-ID: <CA+MoWDqBF5bdQYBaUmpB99Q=YcHYcUxi8Ffo3x4s0B+pmomb+Q@mail.gmail.com>
References: <CA+MoWDp4W5BCA1t_HgEtLhMs1btVTOkbtBytOVtAzJriEZ-16A@mail.gmail.com>
	<20121004074442.180d8f01@nehalam.linuxnetplumber.net>
	<CA+MoWDp=_F9opJbVkv9sDsmoykm7MTUZwRVumKCB0ZqDwD6NoQ@mail.gmail.com>
	<20121004.142335.1467206545795435493.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: shemminger@vyatta.com, mlindner@marvell.com,
	kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121004.142335.1467206545795435493.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 4, 2012 at 8:23 PM, David Miller <davem@davemloft.net> wrote:
> From: Peter Senna Tschudin <peter.senna@gmail.com>
> Date: Thu, 4 Oct 2012 19:32:12 +0200
>
>> I can't understand the advantages of describing each patch as you are
>> asking. "For me" the generic commit message together with the patch
>> makes sense.  Can you please help me on that?
>
> Stop being so dense.
>
> We want to know the implications of the bug being fixed.
>
> Does it potentially cause an OOPS?  Bad reference counting and thus
> potential leaks or early frees?
>
> You have to analyze the implications and ramifications of the bug
> being fixed.  We need that information.
>
> Your commit messages are in fact robotic, they don't describe the
> salient details of what kinds of problems the bug being fixed might
> cause.
>
> It's just "bad error code, this is the script that fixed it, kthx,
> bye" which is pretty much useless for anaylsis.

Thank you David.

What about this as commit message?
--- // --
This patch fixes bug(s) related to return value of function(s). In
some error cases, the function is returning non-negative SUCCESS
value, when the correct would be negative ERROR value.

When on error, returning non negatives values, or SUCCESS, breaks error
propagation, producing unpredictable behavior that are very difficult
to debug.
--- // --





-- 
Peter
