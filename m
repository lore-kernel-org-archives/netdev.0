From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Reproducible panics with tulip
Date: Fri, 18 Mar 2005 22:52:29 +0100
Message-ID: <20050318215229.GA24509@electric-eye.fr.zoreil.com>
References: <1111178167.1147.9.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, netdev@oss.sgi.com
To: Alexander Nyberg <alexn@dsv.su.se>
Content-Disposition: inline
In-Reply-To: <1111178167.1147.9.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alexander Nyberg <alexn@dsv.su.se> :
[rpciod and friends complain from page allocation failure]

You could try to increase /proc/sys/vm/min_free_kbytes but it may just
fix the symptoms. You probably want to disable netpoll as the computer
is getting low on network buffers: it should clean the output a lot...

[...]
> Warning: kfree_skb on hard IRQ c46c3950

... however this one may stick.

--
Ueimor
