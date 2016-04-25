From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4/fib: don't warn when primary address is
 missing if in_dev is dead
Date: Sun, 24 Apr 2016 23:26:56 -0400 (EDT)
Message-ID: <20160424.232656.1674286215462940225.davem@davemloft.net>
References: <d6406682cc84a9de9a52bd31eaa6a372f3251f88.1461269273.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	linux-kernel@vger.kernel.org
To: pabeni@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d6406682cc84a9de9a52bd31eaa6a372f3251f88.1461269273.git.pabeni@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paolo Abeni <pabeni@redhat.com>
Date: Thu, 21 Apr 2016 22:23:31 +0200

> After commit fbd40ea0180a ("ipv4: Don't do expensive useless work
> during inetdev destroy.") when deleting an interface,
> fib_del_ifaddr() can be executed without any primary address
> present on the dead interface.
> 
> The above is safe, but triggers some "bug: prim == NULL" warnings.
> 
> This commit avoids warning if the in_dev is dead
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied, thank you.
