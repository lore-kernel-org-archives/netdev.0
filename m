From: "David S. Miller" <davem@redhat.com>
Subject: Re: af_packet & CHECKSUM_HW
Date: Mon, 17 Nov 2003 12:30:47 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031117123047.55377d3a.davem@redhat.com>
References: <20031115024434.GA12276@gondor.apana.org.au>
	<Xine.LNX.4.44.0311160841500.31201-100000@thoron.boston.redhat.com>
	<20031116205146.GA8477@gondor.apana.org.au>
	<20031117194452.GB18448@vana.vc.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Petr Vandrovec <vandrove@vc.cvut.cz>
In-Reply-To: <20031117194452.GB18448@vana.vc.cvut.cz>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 17 Nov 2003 20:44:52 +0100
Petr Vandrovec <vandrove@vc.cvut.cz> wrote:

> It would be nice if at least kernel did not stomp on skb2->h.raw so
> ptype callback could cope with situation and report to userspace where
> to put checksum. I already discussed it here two or so months ago, and
> only solution I was able to find is that VMware's vmnet have to parse
> itself network headers to find where to put checksum. Nothing for IPv6
> users...

Remind me again why the vmnet driver can't just run skb_checksum()
on packets that have CHECKSUM_HW set?
