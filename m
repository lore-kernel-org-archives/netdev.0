From: Stefan Rompf <srompf@isg.de>
Subject: Re: Patch resubmission: RFC2863 operstatus for 2.5.50
Date: Wed, 04 Dec 2002 10:44:58 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DEDCE9A.61FDEBBC@isg.de>
References: <3DE33D6D.25B9C9B4@isg.de> <20021126.021546.91313706.davem@redhat.com> <3DED2EA9.D812C881@isg.de> <3DED51E9.1080408@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Jeff Garzik wrote:

> Pardon my dumb question, but what parts of RFC2863 require kernel
> additions over and above your link state patch?

the kernel does not know LOWERLAYERDOWN, TESTING, DORMANT, UNKNOWN. They
can be useful when drivers adopt to this scheme.

> Your second patch I am less enthusiastic about than the first... :(

Well, with your opinion I count two against two: I want it, Jamal has
proposed the semantics, and Alexey doesn't want to waste a single bit of
a netlink message for this.

What now?

Stefan
