From: "David S. Miller" <davem@redhat.com>
Subject: Re: Do you know about skb_header_pointer() ?
Date: Thu, 19 Aug 2004 07:17:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040819071750.67f0e924.davem@redhat.com>
References: <200408190721.QAA02944@toshiba.co.jp>
	<20040819094401.GY3921@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yasuyuki.kozakai@toshiba.co.jp, kaber@trash.net, kadlec@blackhole.kfki.hu,
        kisza@securityaudit.hu, netfilter-devel@lists.netfilter.org,
        usagi-core@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20040819094401.GY3921@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 19 Aug 2004 11:44:01 +0200
Harald Welte <laforge@netfilter.org> wrote:

> http://lists.netfilter.org/pipermail/netfilter-devel/2004-August/016277.html

I totally disagree with this change.

The goal was to eliminate any and all linearization done by any
part of the networking, especially on output paths.
