From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: Re: memory leak in net/sched/ipt.c?
Date: Wed, 23 Mar 2005 14:40:36 +0100 (MET)
Message-ID: <Pine.LNX.4.61.0503231438290.10048@yvahk01.tjqt.qr>
References: <E1DE44X-0001QM-00@gondolin.me.apana.org.au>
 <1111581618.1088.72.camel@jzny.localdomain>  <20050323125516.GP3086@postel.suug.ch>
 <1111583497.1089.92.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1111583497.1089.92.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

>I have seen people put little comments of "kfree will work if you
>pass it NULL" - are you saying such assumptions exist all over
>net/sched?

Not only net/sched. The C standard requires that free(NULL) works.


Jan Engelhardt
-- 
