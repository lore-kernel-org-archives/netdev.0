From: Andrew Morton <akpm@osdl.org>
Subject: Re: MSEC_TO_JIFFIES is messed up...
Date: Wed, 12 May 2004 14:07:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040512140729.476ace9e.akpm@osdl.org>
References: <20040512020700.6f6aa61f.akpm@osdl.org>
	<20040512181903.GG13421@kroah.com>
	<40A26FFA.4030701@pobox.com>
	<20040512193349.GA14936@elte.hu>
	<200405121947.i4CJlJm5029666@turing-police.cc.vt.edu>
	<Pine.LNX.4.58.0405121255170.11950@bigblue.dev.mdolabs.com>
	<200405122007.i4CK7GPQ020444@turing-police.cc.vt.edu>
	<20040512202807.GA16849@elte.hu>
	<20040512203500.GA17999@elte.hu>
	<20040512205028.GA18806@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Valdis.Kletnieks@vt.edu, davidel@xmailserver.org, jgarzik@pobox.com,
        greg@kroah.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ingo Molnar <mingo@elte.hu>
In-Reply-To: <20040512205028.GA18806@elte.hu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ingo Molnar <mingo@elte.hu> wrote:
>
> yet another patch - this time it's: complete, covers irda, accelerates
>  HZ=100, unifies the slightly differing namespaces and compiles/boots as
>  well.
> 
> ...
> 
> [hz-cleanup-2.6.6-A2  text/plain (2657 bytes)]

This doesn't have the little round up which some implementations had, so
someone who tries to sleep for 9 millisscondes on a 100HZ box may end up in
a busywait.  Looks risky.

The SCTP version looks like it'll generate awful code, so let's not use
that.
