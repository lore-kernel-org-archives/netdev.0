From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.4/2.6 PATCHES] Change some ip_fragment checks to help IPVS
Date: Tue, 14 Oct 2003 15:51:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031014155152.275270c1.davem@redhat.com>
References: <200310141203.QAA23474@yakov.inr.ac.ru>
	<Pine.LNX.4.44.0310150143460.16055-100000@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, wensong@linux-vs.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.44.0310150143460.16055-100000@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Oct 2003 01:55:43 +0300 (EEST)
Julian Anastasov <ja@ssi.bg> wrote:

> 	One related question: is ip_fragment() backport from 2.6
> to 2.4 planned?

No, it only makes sense in the 2.6.x stack.

2.4.x and 2.6.x networking are wildly different beasts and
you'll therefore need to make the IPVS implementation cope
with that in each tree.
