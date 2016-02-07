From: Paul Moore <pmoore@redhat.com>
Subject: Re: [RFC PATCH v2 12/18] ipv6: Allow request socks to contain IPv6 options.
Date: Sun, 07 Feb 2016 14:56:11 -0500
Message-ID: <2442064.Lu7DBv0u8O@sifl>
References: <1452246774-13241-13-git-send-email-huw@codeweavers.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
To: Huw Davies <huw@codeweavers.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1452246774-13241-13-git-send-email-huw@codeweavers.com>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, January 08, 2016 09:52:48 AM Huw Davies wrote:
> If set, these will that precedence over the parent's options during
                     ^^^^
                     take

> both sending and child creation.  If they're not set, the parent's
> options (if any) will be used.
> 
> This is to allow the security_inet_conn_request() hook to modify the
> IPv6 options in just the same way that it already may do for IPv4.
> 
> Signed-off-by: Huw Davies <huw@codeweavers.com>
> ---
>  include/net/inet_sock.h |  7 ++++++-
>  net/dccp/ipv6.c         | 12 +++++++++---
>  net/ipv4/tcp_input.c    |  3 +++
>  net/ipv6/tcp_ipv6.c     | 12 +++++++++---
>  4 files changed, 27 insertions(+), 7 deletions(-)

-- 
paul moore
security @ redhat
