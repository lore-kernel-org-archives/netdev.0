From: jamal <hadi@cyberus.ca>
Subject: Re: [Patch] net: fix build break when CONFIG_NET_CLS_ACT is not set
Date: 29 Mar 2005 16:12:01 -0500
Message-ID: <1112130720.1076.112.camel@jzny.localdomain>
References: <20050329202506.GI22447@hmsendeavour.rdu.redhat.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Neil Horman <nhorman@redhat.com>
In-Reply-To: <20050329202506.GI22447@hmsendeavour.rdu.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This is being discussed on netdev at the moment. Thomas Graf is working
on a patch.
Thanks for the effort though.

cheers,
jamal

On Tue, 2005-03-29 at 15:25, Neil Horman wrote:
> Patch to fix build break that occurs when CONFIG_NET_CLS_ACT is not set.
> 
> Signed-off-by: Neil Horman <nhorman@redhat.com>
> 
>  cls_fw.c      |    3 ++-
>  cls_route.c   |    3 ++-
>  cls_tcindex.c |    3 ++-
>  cls_u32.c     |    2 ++
>  4 files changed, 8 insertions(+), 3 deletions(-)
> 
