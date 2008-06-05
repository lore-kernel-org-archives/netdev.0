From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [fixed] [patch] Re: [bug] stuck localhost TCP connections,
 v2.6.26-rc3+
Date: Thu, 5 Jun 2008 21:00:53 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806052059380.31672@wrl-59.cs.helsinki.fi>
References: <20080603094057.GA29480@elte.hu> <Pine.LNX.4.64.0806032245490.3474@wrl-59.cs.helsinki.fi>
 <Pine.LNX.4.64.0806040052270.3474@wrl-59.cs.helsinki.fi>
 <20080603.150344.145518113.davem@davemloft.net>
 <Pine.LNX.4.64.0806040208350.7315@wrl-59.cs.helsinki.fi> <20080605142244.GA19216@elte.hu>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-650765930-1212688853=:31672"
Cc: David Miller <davem@davemloft.net>, mcmanus@ducksong.com,
	peterz@infradead.org, LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, rjw@sisk.pl,
	Andrew Morton <akpm@linux-foundation.org>, johnpol@2ka.mipt.ru
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759077AbYFESBI@vger.kernel.org>
In-Reply-To: <20080605142244.GA19216@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-650765930-1212688853=:31672
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Thu, 5 Jun 2008, Ingo Molnar wrote:

> 
> * Ilpo Järvinen <ilpo.jarvinen@helsinki.fi> wrote:
> 
> > [PATCH] tcp DEFER_ACCEPT: fix racy access to listen_sk
> 
> i unapplied the reverts then applied your fix, and got this hang after 
> 1.5 hours of testing:
> 
>  titan:~> netstat -nt
>  Active Internet connections (w/o servers)
>  Proto Recv-Q Send-Q Local Address           Foreign Address   State
>  tcp        0  65032 10.0.1.14:39454         10.0.1.19:3632    ESTABLISHED
> 
> 10.0.1.14 is this box, Core2Duo dual-core. 10.0.1.19 is another box with 
> 16 CPUs.

Did 10.0.1.19 too have the fix (the receiving end is the important 
one to have this fix)?

-- 
 i.
---696208474-650765930-1212688853=:31672--
