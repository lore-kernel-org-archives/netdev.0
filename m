From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fw: kernel 2.6 libipq kernel hang
Date: Sat, 04 Jun 2005 18:40:43 +0200
Message-ID: <42A1D98B.7030400@trash.net>
References: <20050406155828.1584d7cd.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mailinglist.chris@gmail.com
In-Reply-To: <20050406155828.1584d7cd.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> 
> Begin forwarded message:
> 
> Date: Wed, 6 Apr 2005 15:12:05 -0400
> From: Mailing List <mailinglist.chris@gmail.com>
> To: linux-kernel@vger.kernel.org
> Subject: kernel 2.6 libipq kernel hang
> 
> /sbin/iptables -t mangle -A POSTROUTING -d 192.168.3.0/24 -j QUEUE
> /sbin/iptables -t mangle -A PREROUTING -s 192.168.3.0/24 -j QUEUE
> 
> If anyone has any suggestions about what I am doing wrong in either
> the libipq program or the client or server programs, or any ideas
> about what is going on with netlink, please let me know.

Please try latest -git, Harald fixed a bug that could cause a deadlock
when ip_queue was used in PRE_ROUTING.

Regards
Patrick
