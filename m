From: Derek Fawcus <dfawcus@cisco.com>
Subject: Re: [PATCH] IPv6: Fix Prefix Length of Link-local Addresses
Date: Thu, 10 Oct 2002 01:10:48 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021010011048.D8102@edi-view1.cisco.com>
References: <20021010002902.A3803@edi-view1.cisco.com> <20021009.162438.82081593.davem@redhat.com> <uu1jv9o3j.wl@sfc.wide.ad.jp> <20021009.164504.28085695.davem@redhat.com> <ur8ez9n8d.wl@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Yuji Sekiya <sekiya@sfc.wide.ad.jp>
In-Reply-To: <ur8ez9n8d.wl@sfc.wide.ad.jp>; from sekiya@sfc.wide.ad.jp on Thu, Oct 10, 2002 at 09:00:34AM +0900
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 10, 2002 at 09:00:34AM +0900, Yuji Sekiya wrote:
> 
> I have cisco box which installed IPv6 IOS.

Did I mention any specific names :-)

> But it defines no prefix length at an interface,

Not really suprising,  it's meaningless.

> FastEthernet4/1 is up, line protocol is up
>   IPv6 is enabled, link-local address is FE80::201:64FF:FEA3:ED55
> 
> and outgoing interface of routing table is NULL ? :-)
> 
> L   FE80::/10 [0/0]
>      via ::, Null0, 7w0d

Well,  that prefix is on all ipv6 enabled interfaces.  so again a bit
meaningless.  Anyway,  that's showing a Local entry not a connected entry.

DF
