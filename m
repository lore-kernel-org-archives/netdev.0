From: Derek Fawcus <dfawcus@cisco.com>
Subject: Re: [PATCH] IPv6: Fix Prefix Length of Link-local Addresses
Date: Thu, 10 Oct 2002 01:02:34 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021010010234.B8102@edi-view1.cisco.com>
References: <20021010002902.A3803@edi-view1.cisco.com> <20021009.162438.82081593.davem@redhat.com> <uu1jv9o3j.wl@sfc.wide.ad.jp> <20021009.164504.28085695.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sekiya@sfc.wide.ad.jp, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20021009.164504.28085695.davem@redhat.com>; from davem@redhat.com on Wed, Oct 09, 2002 at 04:45:04PM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Oct 09, 2002 at 04:45:04PM -0700, David S. Miller wrote:
>    From: Yuji Sekiya <sekiya@sfc.wide.ad.jp>
>    Date: Thu, 10 Oct 2002 08:41:52 +0900
>    
>    The reason we change the prefix length  from /10 to /64 is
>    following spec and adapting other imprementations.
> 
> I think Derek's explanation shows that the specification
> allows the /10 behavior.

But as someone else pointed out (sorry I'm to lazy to check the thread),
one would still be able to manually adjust the Linux routing table to get it
into the /10 behaviour.

So frankly I'm not too fussed which behaviour is the default,  I was just
pointing out (what to me seemed to be) a change of dubious quality.

(Then letting myself get into an argument over specs - when will I learn :-)

DF
