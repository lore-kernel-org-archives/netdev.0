From: James Morris <jmorris@redhat.com>
Subject: Re: kernel bug at sched.c:564! + linux kernel 2.4.25
Date: Tue, 27 Jul 2004 14:39:25 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Xine.LNX.4.44.0407271439001.7805-100000@dhcp83-76.boston.redhat.com>
References: <200407272102.58638.vkondra@mail.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Matt Mackall <mpm@selenic.com>, Niranjan <niranjan_cs2905@yahoo.com>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Vladimir Kondratiev <vkondra@mail.ru>
In-Reply-To: <200407272102.58638.vkondra@mail.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 27 Jul 2004, Vladimir Kondratiev wrote:

> We also saw the same (crypto modules goes to sleep).
> Due to this, we decided to not use cryptoapi for our wireless driver, but 
> compile the same crypto functions into the driver. I know this is code 
> duplication, but Tx and Rx paths work in BH context (I reschedule it on IRQ 
> Rx to use cheaper time).
> 
> Do cryptoapi maintainers aware of this issue?

The crypto functions should be safe to use in softirq context.


- James
-- 
James Morris
<jmorris@redhat.com>
