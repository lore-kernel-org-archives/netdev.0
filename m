From: Derek Fawcus <dfawcus@cisco.com>
Subject: Re: [PATCH] IPv6: Fix Prefix Length of Link-local Addresses
Date: Thu, 10 Oct 2002 00:51:49 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021010005149.A4699@edi-view1.cisco.com>
References: <20021009234421.J29133@edinburgh.cisco.com> <20021009.161414.63434223.davem@redhat.com> <20021010002902.A3803@edi-view1.cisco.com> <20021009.162438.82081593.davem@redhat.com> <uu1jv9o3j.wl@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Yuji Sekiya <sekiya@sfc.wide.ad.jp>
In-Reply-To: <uu1jv9o3j.wl@sfc.wide.ad.jp>; from sekiya@sfc.wide.ad.jp on Thu, Oct 10, 2002 at 08:41:52AM +0900
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 10, 2002 at 08:41:52AM +0900, Yuji Sekiya wrote:
> 
> The reason we change the prefix length  from /10 to /64 is
> following spec and adapting other imprementations.

I said I wouldn't comment futher on the spec issue.

I know of at least one other implementation that allows any set of bits
within the link local range to be specified.  (Two if you include the
current/previous Linux behaviour :-)

Changing to restrict the allowed link local addresses doesn't _enhance_
interoperability.  Leaving it as it is/was doesn't harm anything.

DF
