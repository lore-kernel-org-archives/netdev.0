From: Stefan Rompf <srompf@isg.de>
Subject: Re: Patch: Idea for RFC2863 conform OperStatus
Date: Mon, 14 Oct 2002 14:42:22 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DAABBAE.79E22EB6@isg.de>
References: <200210132204.CAA09385@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru, jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alexey, Jamal,

the first version of this patch just added the feature to distribute
state changes created by netif_carrier_on()/_off() inside the kernel and
to netlink via netdev_state_change(). This is still the part most
important to me - not only in 2.5, but also as a 2.4 backport.

I don't think RFC2863 state keeping makes much sense if we cannot
forward the results to userspace. So if you are happy with keeping the
current semantics, but using the more sophisticated implementation of
forwarding worked out last weekend, I'll be happy to provide a new patch
(also adressing Jamal's nitpicks). Just agree on one way.

Cheers, Stefan
