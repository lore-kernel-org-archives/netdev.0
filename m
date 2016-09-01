From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RT PATCH 2/2] net: add a lock around icmp_sk()
Date: Thu, 01 Sep 2016 06:11:00 -0700
Message-ID: <1472735460.5019.21.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160831160049.14303-1-bigeasy@linutronix.de>
         <20160831160049.14303-2-bigeasy@linutronix.de>
         <1472661463.14381.327.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160901081146.nabh52qssjkvztxz@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-rt-users@vger.kernel.org, linux-kernel@vger.kernel.org,
        tglx@linutronix.de, Steven Rostedt <rostedt@goodmis.org>,
        netdev@vger.kernel.org
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160901081146.nabh52qssjkvztxz@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-09-01 at 10:11 +0200, Sebastian Andrzej Siewior wrote:

> On !RT local_lock() is preempt_disable().
> On RT local_lock() is a per-CPU sleeping spinlock which can be taken
> recursively by the owner.

Ok, thanks for the explanation, the 'recursively' part I was not aware
of ;)
