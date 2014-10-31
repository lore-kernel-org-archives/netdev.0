From: Heiko Schocher <hs@denx.de>
Subject: Re: Mistake in commit 0d961b3b52f566f823070ce2366511a7f64b928c breaks
 cpsw non dual_emac mode.
Date: Fri, 31 Oct 2014 07:49:14 +0100
Message-ID: <545330EA.60303@denx.de>
References: <20141028170242.GA24112@csclub.uwaterloo.ca> <20141030.154323.1702996635200338108.davem@davemloft.net>
Reply-To: hs@denx.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: lsorense@csclub.uwaterloo.ca, linux-kernel@vger.kernel.org,
	mugunthanvnm@ti.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141030.154323.1702996635200338108.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David, Lennart,

Am 30.10.2014 20:43, schrieb David Miller:
> From: "Lennart Sorensen"<lsorense@csclub.uwaterloo.ca>
> Date: Tue, 28 Oct 2014 13:02:42 -0400
>
>> I believe commit 0d961b3b52f566f823070ce2366511a7f64b928c made a mistake
>> while correcting a bug.

Seems I missed your original patch ... looked in it here:

https://lkml.org/lkml/2014/10/28/837

and I think you are correct, thanks for this fix. You can add my
Acked-by: Heiko Schocher <hs@denx.de>
if you post a corrected v2, as David suggested.

bye,
Heiko

> This patch submission is not properly formed.
>
> You subject line should be of the form:
>
> subsystem: Description.
>
> "subsystem" here would be "cpsw: " or something like that.
>
> Secondly, you should not refer to a commit ID in the patch
> Subject line, instead just describe exactly what is being
> fixed in the most succinct yet complete manner that is
> possible.
>
> Thirdly, when you do refer to commit ID's in your commit
> message body you must do so in the following format:
>
> ${SHA1_ID} ("Commit message header line text.")
>
> The commit message body is also not a place to have a general
> discussion.  Please avoid saying things like "I think", for example.
> State facts, and be exact about what the problem is and exactly
> how you are fixing it.
>
> Because this commit message will be read by others looking at your
> change days, weeks, years from now.
>
> Thanks.
>

-- 
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
