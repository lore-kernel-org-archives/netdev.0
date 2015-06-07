From: Firo Yang <firogm@gmail.com>
Subject: Re: [PATCH] fib_trie: Fix potential null pointer dereference
Date: Sun, 7 Jun 2015 21:42:11 +0800
Message-ID: <20150607134211.GA16700@firo>
References: <1433590553-4672-1-git-send-email-firogm@gmail.com>
 <1433592304.1895.73.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150607060129.GA9265@firo>
 <alpine.DEB.2.02.1506070835310.2108@localhost6.localdomain6>
 <20150607131924.GA16087@firo>
 <alpine.DEB.2.10.1506071520410.2716@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1506071520410.2716@hadrien>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 07, 2015 at 03:23:57PM +0200, Julia Lawall wrote:
>> >I think that many people would make the same mistake when looking at the
>> >code.  The change doesn't seem to hurt anything?
>> Actually, yes. But it does imporve nothing but coding style.
>> I think Alexander's code style make function more compact is also a
>> good code style. So, just keep it original.
>
>Still it makes noise when other people look at the code and find that it
>looks odd.  Removing the false positive in smatch won't completely help,
>because people could look at the code for other reasons.

You said it! I will do the improvement.

Firo

>
>But, as you like.
>
>julia

-- 
