From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: Re: [PATCH 19/20] drivers/net/ethernet/marvell/skge.c: fix error
 return code
Date: Thu, 4 Oct 2012 19:32:12 +0200
Message-ID: <CA+MoWDp=_F9opJbVkv9sDsmoykm7MTUZwRVumKCB0ZqDwD6NoQ@mail.gmail.com>
References: <1349281090-10013-20-git-send-email-peter.senna@gmail.com>
	<20121003092508.6a7da662@nehalam.linuxnetplumber.net>
	<CA+MoWDp4W5BCA1t_HgEtLhMs1btVTOkbtBytOVtAzJriEZ-16A@mail.gmail.com>
	<20121004074442.180d8f01@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: mlindner@marvell.com, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121004074442.180d8f01@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> Stephen, I do not want to include function names on the commit
>> message. What do you think about this updated message, is it
>> acceptable?
>>
>
> No still to generic, it needs to be written by a human examining
> the file and understanding what the cause and effect of the bug
> is.

Stephen I've understood what you want. But it is not clear to me why
you want. Let me show what Coccinelle produces as output:

[peter@ace linux-next]$ spatch ../../cocci/ret4.cocci -dir .
...
* TODO [[view:./drivers/net/ethernet/sun/sungem.c::face=ovl-face1::linb=2894::colb=1::cole=3][./drivers/net/ethernet/sun/sungem.c::2894]]
[[view:./drivers/net/ethernet/sun/sungem.c::face=ovl-face2::linb=2966::colb=1::cole=3][./drivers/net/ethernet/sun/sungem.c::2966]]
[[view:./drivers/net/ethernet/sun/sungem.c::face=ovl-face2::linb=3015::colb=1::cole=7][./drivers/net/ethernet/sun/sungem.c::3015]]
...

There is "no" automatic code transformation. The semantic patch I'm
using only points out where to investigate to change, or not, the
code. The output is in Emcas org-mode format. So I can tell you that
the patches are not being robot generated. I'm making the patches, one
by one, with great help of Coccinelle, but I'm making the code changes
by hand.

I can't understand the advantages of describing each patch as you are
asking. "For me" the generic commit message together with the patch
makes sense.  Can you please help me on that?

>



-- 
Peter
