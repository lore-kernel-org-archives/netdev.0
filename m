From: "Carlos Velasco" <carlosev@newipnet.com>
Subject: Re: Bug? ARP with wrong src IP address
Date: Fri, 25 Jul 2003 20:24:19 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307252024190066.051F80CE@192.168.128.16>
References: <200307241728270476.0031BAB0@192.168.128.16>
 <Pine.LNX.4.44.0307241849341.2177-100000@l>
 <20030724091007.68923845.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: bdschuym@pandora.be, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <20030724091007.68923845.davem@redhat.com>
To: "David S. Miller" <davem@redhat.com>, "Julian Anastasov" <ja@ssi.bg>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 24/07/2003 at 9:10 David S. Miller wrote:

>The hidden patch is not necessary with current kernels and arpfilter.

arp_filter doesn't work.
If I'm not wrong it's applied when you have two or more interfaces in the same subnet. This is not the case.

I have applied hidden patch and it works.
If I'm not wrong, the hidden patch makes linux behave like other OS, separating selected interfaces of another interfaces.
It does not break anything because it's all configurable in /proc.

Maybe it would be good including it in the kernel package?

Regards,
Carlos Velasco
