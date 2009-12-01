From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: warning: massive change to conditional coding style in net?
Date: Tue, 01 Dec 2009 17:49:36 +0100
Message-ID: <4B154920.40203@gmail.com>
References: <4B13A025.7000103@gmail.com> <1259603798.29779.293.camel@Joe-Laptop.home> <4B153F9B.7050502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joe Perches <joe@perches.com>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754405AbZLAQtf@vger.kernel.org>
In-Reply-To: <4B153F9B.7050502@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

William Allen Simpson a =C3=A9crit :
> Joe Perches wrote:
>> If it makes getting tcp cookies accepted difficult,
>> a reversion is simple.  That style isn't as important.
>>
> Then why make an *un*important (yet sweeping) change?

Because this is time :

We usually makes cleanup patches just before the release
of a new linux kernel, to minimize effects on developer trees.

We know linux-2.6.32 is about to be released by Linus,
and all major 2.6.33 patches are already queued in net-next-2.6
to be pushed to Linus as soon as the window opens.

This is the perfect time for cleanups. Doing cleanups is a good
way to learn linux code, before doing more complex things.

If you take a look at queued patches in net-next-2.6, maybe less
than 5 % are cleanups.

But this rule can be changed, if your patches are ready for inclusion,
David might revert the jumbo cleanup to ease your job. Just ask.
