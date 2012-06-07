From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Deadlock, L2TP over IP are not working, 3.4.1
Date: Fri, 8 Jun 2012 00:37:52 +0200
Message-ID: <20120607223752.GA4475@electric-eye.fr.zoreil.com>
References: <7ed49f446365ac625437702d92946add@visp.net.lb> <20120607205356.GA2491@electric-eye.fr.zoreil.com> <1339104606.6001.4.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryshchenko <denys@visp.net.lb>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1339104606.6001.4.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet <eric.dumazet@gmail.com> :
[...]
> If LLTX is used, this means several cpus can execute this code at the
> same time.
> 
> You need percpu stats, or use atomic primitives.

Would adding percpu stats not be frown upon ?

As atomic will defeat the 64 bits stats on 32 bits, I should probably stick
to plain bh disabling lock.

-- 
Ueimor
