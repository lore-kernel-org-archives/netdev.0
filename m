From: Derek Fawcus <dfawcus@cisco.com>
Subject: Re: [PATCH] IPv6: Fix Prefix Length of Link-local Addresses
Date: Thu, 10 Oct 2002 00:36:28 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021010003627.A4481@edi-view1.cisco.com>
References: <20021009234421.J29133@edinburgh.cisco.com> <20021009.161414.63434223.davem@redhat.com> <20021010002902.A3803@edi-view1.cisco.com> <20021009.162438.82081593.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sekiya@sfc.wide.ad.jp, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20021009.162438.82081593.davem@redhat.com>; from davem@redhat.com on Wed, Oct 09, 2002 at 04:24:38PM -0700
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Oct 09, 2002 at 04:24:38PM -0700, David S. Miller wrote:
>    From: Derek Fawcus <dfawcus@cisco.com>
>    Date: Thu, 10 Oct 2002 00:29:02 +0100
> 
>    There are areas where the TAHI tests expect a certain behaviour
>    when more than one behaviour is acceptable.
> 
> Great, that's what I was trying to find out.
> 
> Now I just need to know if this link-local prefix case
> is one such issue. :-)

That I can't answer,  since I've not had that one specifically thrown at
me as a test failure condition.

However,  in a previous email I did indicate the two different ICMPv6
errors that could be generated.  So I guess it's a case of see if this
was a TAHI failure,  and if so then is it that TAHI want's to get a
'no route to destination' when 'address unreachable' should suffice.

DF
