From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH] fib_trie: Fix potential null pointer dereference
Date: Sun, 7 Jun 2015 15:23:57 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1506071520410.2716@hadrien>
References: <1433590553-4672-1-git-send-email-firogm@gmail.com> <1433592304.1895.73.camel@edumazet-glaptop2.roam.corp.google.com> <20150607060129.GA9265@firo> <alpine.DEB.2.02.1506070835310.2108@localhost6.localdomain6> <20150607131924.GA16087@firo>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Julia Lawall <julia.lawall@lip6.fr>,
	Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Firo Yang <firogm@gmail.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20150607131924.GA16087@firo>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >I think that many people would make the same mistake when looking at the
> >code.  The change doesn't seem to hurt anything?
> Actually, yes. But it does imporve nothing but coding style.
> I think Alexander's code style make function more compact is also a
> good code style. So, just keep it original.

Still it makes noise when other people look at the code and find that it
looks odd.  Removing the false positive in smatch won't completely help,
because people could look at the code for other reasons.

But, as you like.

julia
