From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH]: fixed typo of reassembly.c
Date: Fri, 1 Oct 2004 15:19:23 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041001151923.261b42b3.davem@davemloft.net>
References: <200409301023.i8UANRGp002783@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>
In-Reply-To: <200409301023.i8UANRGp002783@toshiba.co.jp>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 30 Sep 2004 19:23:26 +0900 (JST)
Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp> wrote:

> This patch fixes byte ordering. Please apply this.

It is textual fix only, do you realize this?
Both ntohs() and htons() perform the same transformation
on a 16-bit data item.  It really does not matter which
one you actually use, in practice.

I will apply your patch anyways, I just wanted to be
clear that this does not actually fix any bug. :-)

THanks.
