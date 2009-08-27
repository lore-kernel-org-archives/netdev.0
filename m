From: Andi Kleen <andi@firstfloor.org>
Subject: Re: TCP keepalive timer problem
Date: Thu, 27 Aug 2009 15:35:22 +0200
Message-ID: <87skfdl6qt.fsf@basil.nowhere.org>
References: <0939B589FC103041945B9F13274963E303B1A9D4@CORPUSMX90A.corp.emc.com>
	<4A93E36C.8070502@gmail.com>
	<0939B589FC103041945B9F13274963E303B1AD89@CORPUSMX90A.corp.emc.com>
	<4A967FCE.3000807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Li_Xin2@emc.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752709AbZH0Nf1@vger.kernel.org>
In-Reply-To: <4A967FCE.3000807@gmail.com> (Eric Dumazet's message of "Thu, 27 Aug 2009 14:45:02 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> writes:
>
> Now, 7200 seconds might be inappropriate for special needs, and considering
> there is no way to change tcp_retries2 for a given socket (only choice being the global
> tcp_retries2 setting), I would vote for a change in our stack, to *relax* RFC,
> and get smaller keepalive timers if possible.

I think the better fix would be to just to only do that when
tcp_retries2 > keep alive time. So keep the existing behaviour
with default keep alive, but switch when the user defined
a very short keep alive.

-Andi


-- 
ak@linux.intel.com -- Speaking for myself only.
