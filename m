From: "David S. Miller" <davem@redhat.com>
Subject: Re: 2.6: QoS scheduling not working with IP-over-IP
Date: Wed, 11 Feb 2004 20:05:49 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040211200549.736fa8b3.davem@redhat.com>
References: <Pine.LNX.4.44.0402101324350.810-100000@atlantis.knm.org.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Dawid Kuroczko <qnex@atlantis.knm.org.pl>
In-Reply-To: <Pine.LNX.4.44.0402101324350.810-100000@atlantis.knm.org.pl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[ moving from linux-kernel to correct mailing list... ]

Czesc Dawid,

On Tue, 10 Feb 2004 13:36:32 +0100 (CET)
Dawid Kuroczko <qnex@atlantis.knm.org.pl> wrote:

> There seems to be a bug in QoS scheduling code related to IP-over-IP
> tunnels (ipip.ko).  My setup is a bit unusual -- my default route
> goes through tunl1, so I want it shaped.  It worked fine with 2.4,
> but it doesn't with 2.6 (2.6.1 and 2.6.2, I made a transition quite
> recently).

Can you assign QoS schedulers and classifiers successfully to eth0
or some other non ipip device?

Does it work with 'tunl0' instead of 'tunl1'?

Stephen, I bet this problem got introduced when we moved ipip.c over
to dynamic netdevice allocation, can you take a look?
