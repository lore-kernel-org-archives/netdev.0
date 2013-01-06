From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Major network performance regression in 3.7
Date: Sat, 05 Jan 2013 16:02:03 -0800
Message-ID: <1357430523.1678.4901.camel@edumazet-glaptop>
References: <20130105214958.GA19814@1wt.eu>
	 <1357427926.1678.4771.camel@edumazet-glaptop>
	 <20130105232913.GQ16031@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130105232913.GQ16031@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-01-06 at 00:29 +0100, Willy Tarreau wrote:

> > 2) Another possibility would be that Myri card/driver doesnt like very
> > well high order pages.
> 
> It looks like it has not changed much since 3.6 :-/ I really suspect
> something is wrong with memory allocation. I have tried reverting many
> patches affecting the mm/ directory just in case but I did not come to
> anything useful yet.
> 

Hmm, I was referring to TCP stack now using order-3 pages instead of
order-0 ones

See commit 5640f7685831e088fe6c2e1f863a6805962f8e81
(net: use a per task frag allocator)

Could you please post :

ethtool -S eth0
