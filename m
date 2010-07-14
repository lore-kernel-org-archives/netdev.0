From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: Raise initial congestion window size / speedup slow start?
Date: Thu, 15 Jul 2010 00:36:33 +0200
Message-ID: <20100714223633.GJ6682@nuttenaction>
References: <4C3D94E3.9080103@wildgooses.com>
 <4C3DD5EB.9070908@tmr.com>
 <20100714.111553.104052157.davem@davemloft.net>
 <4C3E0684.5060409@wildgooses.com>
 <4C3E1B54.40604@hp.com>
 <20100714203919.GD6682@nuttenaction>
 <4C3E34AB.2060405@wildgooses.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, davidsen@tmr.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ed W <lists@wildgooses.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4C3E34AB.2060405@wildgooses.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Ed W | 2010-07-14 23:05:31 [+0100]:

>Initial cwnd was changed (increased) in the past (rfc3390) and the
>RFC claims that studies then suggested that the benefits were all
>positive. Some reasonably smart people have suggested that it might
>be time to review the status quo again so it doesn't seem completely
>obvious that the current number is optimal?

Do you cite "An Argument for Increasing TCP's Initial Congestion Window"?
People at google stated that a CWND of 10 seems to be fair in their
measurements. 10 because the test setup was equipped with a reasonable large
link capacity? Do they analyse their modification in environments with a small
BDP (e.g. multihop MANET setup, ...)? I am curious, but We will see what
happens if TCPM adopts this.

>That RFC is a subtle read - it appears to give more specific guidance
>on what to do in certain situations, but I'm not sure I see that it
>improves slow start convergence speed for my situation (large RTT)?
>Would you mind highlighting the new bits for those of us a bit newer
>to the subject?

The objection/hint was more of general nature - not specific for larger RTTs.
Environments with larger RTTs are disadvantaged because TCP is ACK clocked.
Half-truth statement for my part because RTT fairness is and was an issue at
the development of new congestion control algorithms: BIC, CUBIC and friends.

>>Partial local issues can already be "fixed" via route specific ip options -
>>see initcwnd.
>
>Oh, excellent.  This seems like exactly what I'm after.  (Thanks
>Stephen Hemminger!)

Great, you are welcome! ;-)


Hagen
