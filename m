From: Alex Bennee <kernel-hacker@bennee.com>
Subject: Re: r8169 ethernet hangs after a pm-suspend (and resume)
Date: Wed, 9 Sep 2009 10:37:02 +0100
Message-ID: <b2cdc9f30909090237t67e8c478he6f6e92f167d6a2b@mail.gmail.com>
References: <b2cdc9f30909090013q1741da26la73da66f1eef975f@mail.gmail.com>
	 <20090909092822.GA18355@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753015AbZIIJm1@vger.kernel.org>
In-Reply-To: <20090909092822.GA18355@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2009/9/9 Francois Romieu <romieu@fr.zoreil.com>:
> Alex Bennee <kernel-hacker@bennee.com> :
> [...]
>> I've just recently gotten suspend working on my system. Unfortunately
>> after the resume event I loose access to the network.
>> As far as the system is concerned the network is configured properly
>> but every attempt to ping local nodes fails with "Host not reachable".
>
> Can the problem be described as "gigabit link setting does not survive
> suspend/resume" ?

How could I check?

AFAIK my network only runs at 100Mbs anyway. I tried poking about with
ethtool to see if could determine any more diagnostics but it didn't know
much about the card.

>
> --
> Ueimor
>



-- 
Alex, homepage: http://www.bennee.com/~alex/
http://www.half-llama.co.uk
