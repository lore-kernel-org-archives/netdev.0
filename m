From: Pablo Neira <pablo@eurodev.net>
Subject: [PATCH 0/4] [NETLINK] unify checkings for clean messages and fix
 indentation
Date: Fri, 11 Feb 2005 01:13:47 +0100
Message-ID: <420BF8BB.5000809@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

The following patches introduce a new function that check that the 
netlink messages received are clean. Actually some people performs such 
checkings, some don't and others simply do some half of them. I think 
that we must unify the behaviour of a netlink socket when it has to 
reply to malformed messages. Attached an indentation fix for netlink.h 
as well.

00indent-fix.patch:
        fixes broken indentation in netlink.h
01process_skb.patch:
       introduces the new function called netlink_check_skb that does 
the sanity checkings for received messages.
02xfrm.patch:
       the modification to make xfrm_user use such new function.
03rtnetlink.patch:
       same thing for rtnetlink.

The 02 and 03 patches are straightforward conversions. If you are ok 
with this, I could post more patches to make other netlink sockets use 
this new function.

--
Pablo
