From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][IPSEC] IPsec policy can be matched by ICMP type and
 code
Date: Mon, 9 Aug 2004 17:07:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040809170705.6ab75c5f.davem@redhat.com>
References: <20040809175404.301bd60a@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Masahide Nakamura <nakam@linux-ipv6.org>
In-Reply-To: <20040809175404.301bd60a@localhost>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 9 Aug 2004 17:54:04 +0900
Masahide Nakamura <nakam@linux-ipv6.org> wrote:

> Thinking of raw socket (in outbound case), the patch supports only
> ICMP; it is out of scope such packet as user-land builds non-ICMP data
> (e.g. TCP/UDP) and sends through raw socket. IMO this behavior is
> enough, however does anybody have comments?

Truly %100 RAW sockets should have their packets untouched by
the kernel.  User wants exactly that packet to be sent onto
the wire.
