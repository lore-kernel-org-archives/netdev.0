From: "David S. Miller" <davem@redhat.com>
Subject: Re: Remote DoS vulnerability in Linux kernel 2.6.x (fwd)
Date: Wed, 30 Jun 2004 14:42:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040630144230.1d52864b.davem@redhat.com>
References: <Xine.LNX.4.44.0406301423320.32212-100000@thoron.boston.redhat.com>
	<Xine.LNX.4.44.0406301507320.32316-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@lists.netfilter.org, laforge@netfilter.org,
        netdev@oss.sgi.com, arjanv@redhat.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0406301507320.32316-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 30 Jun 2004 15:11:25 -0400 (EDT)
James Morris <jmorris@redhat.com> wrote:

> FYI, I have audited options parsing code in TCP, IPv4 input and Netfilter 
> for any similar problems and not found any.  Further review would be 
> useful (I have not looked at the IPv6 header parsing for example).

I can't find any other cases.

This bug only came up because up the huge change Rusty and Harald did
to make these modules not access the SKB header data directly, and
instead to use local on-stack copies and skb_copy_bits().
