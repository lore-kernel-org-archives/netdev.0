From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC: 2.6 patch] let NET_CLS_ACT no longer depend on
	EXPERIMENTAL
Date: Sat, 04 Mar 2006 13:52:21 -0500
Message-ID: <1141498341.5185.32.camel@localhost.localdomain>
References: <20060304160755.GB9295@stusta.de>  <4409C6BA.60803@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751905AbWCDSw4@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <4409C6BA.60803@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-04-03 at 17:56 +0100, Patrick McHardy wrote:
> Adrian Bunk wrote:
> > This option should IMHO no longer depend on EXPERIMENTAL.
> > 
> > 
> > Signed-off-by: Adrian Bunk <bunk@stusta.de>
> > 
> > ---
> > 
> > This patch was already sent on:
> > - 12 Feb 2006
> 
> Yesterday I managed to crash my machine playing around with tc actions
> within minutes. I haven't looked into it yet, but it seems it still
> needs more testing.

Simple: Fix the bug and submit a patch. If you cant find the cause post
what you are doing. 

What is the metric for going from experimental to non-experimental?
I surely hope it doesnt come to some irrational reasoning like
"Patrick found a bug"[1]. 
- It has been around since 2.6.7/8;
- I use it extensively on about 10 machines since (I am pretty sure a
lot more extensively than Patrick)
- I know people who use it extensively
- I am pretty sure there are people that i dont know who use it
extensively 

So on Adrian's patch and above reasoning:

ACKed-by: Jamal Hadi Salim <hadi@cyberus.ca>

cheers,
jamal

[1]If you used half of that logic on netfilter it would still be
experimental or rather should be demoted to experimental.
