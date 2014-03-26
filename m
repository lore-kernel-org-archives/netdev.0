From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/7] atm: replace del_timer by del_timer_sync
Date: Wed, 26 Mar 2014 15:31:57 -0700
Message-ID: <1395873117.12610.269.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1395869625-15209-1-git-send-email-Julia.Lawall@lip6.fr>
	 <1395869625-15209-3-git-send-email-Julia.Lawall@lip6.fr>
	 <1395871015.12610.254.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAGK4HS-4Lom2=CNR=tiX59xdorENPJdZMVncw10xiOOqZAkBwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Julia Lawall <Julia.Lawall@lip6.fr>,
	"David S. Miller" <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org, tglx@linutronix.de,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGK4HS-4Lom2=CNR=tiX59xdorENPJdZMVncw10xiOOqZAkBwA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-03-26 at 15:19 -0700, Vijay Subramanian wrote:
> >
> > It seems this timer rearms itself, so this patch wont be enough I fear.
> >
> >
> >
> Does that matter? It seems del_timer_sync() may be intended to work
> despite this (i.e. timer will not fire after call to this function).
> My earlier attempt to fix a similar issue in sch_red.c resulted in
> this explanation.
> http://www.spinics.net/lists/netdev/msg256410.html

I know this very well, thank you.

If documentation is stale, it needs clarification.

If not, we need to make sure timer wont be restarted.
