From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] [NETLINK] unify checkings for clean messages
Date: Sat, 12 Feb 2005 02:16:59 +0100
Message-ID: <420D590B.9040404@trash.net>
References: <420BF8C3.3050305@eurodev.net> <20050210173201.21da89e5.davem@davemloft.net> <420D2128.5000803@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: Pablo Neira <pablo@eurodev.net>
In-Reply-To: <420D2128.5000803@eurodev.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Pablo Neira wrote:

> 01process_skb.patch:
>      introduces the new function called netlink_process_skb that does 
> the sanity checkings for received messages.
> 02xfrm.patch:
>      the modification to make xfrm_user use such new function.
> 03rtnetlink.patch:
>      same thing for rtnetlink.

They all look good to me. Depending on what happens with the
loginuid patch, audit_receive_skb might be another candidate
for replacement.

Regards
Patrick
