From: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: Re: [PATCH net-next v5 1/5] netlink: extended ACK reporting
Date: Wed, 12 Apr 2017 09:32:59 -0600
Message-ID: <dd9f0bb0-df0d-bf04-9d17-90d611af7cbc@cumulusnetworks.com>
References: <20170412123408.22012-1-johannes@sipsolutions.net>
 <20170412123408.22012-2-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
        Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170412123408.22012-2-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 4/12/17 6:34 AM, Johannes Berg wrote:
> From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> 
> Add the base infrastructure and UAPI for netlink extended ACK
> reporting. All "manual" calls to netlink_ack() pass NULL for
> now and thus don't get extended ACK reporting.
> 
> Big thanks goes to Pablo Neira Ayuso for not only bringing up
> the whole topic at netconf (again) but also coming up with the
> nlattr passing trick and various other ideas.
> 
> Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> ---
>  crypto/crypto_user.c              |  3 +-
>  drivers/infiniband/core/netlink.c |  5 +--
>  drivers/scsi/scsi_netlink.c       |  2 +-
>  include/linux/netlink.h           | 26 +++++++++++++-
>  include/net/netlink.h             |  3 +-
>  include/uapi/linux/netlink.h      | 32 ++++++++++++++++++
>  kernel/audit.c                    |  2 +-
>  net/core/rtnetlink.c              |  3 +-
>  net/core/sock_diag.c              |  3 +-
>  net/decnet/netfilter/dn_rtmsg.c   |  2 +-
>  net/hsr/hsr_netlink.c             |  4 +--
>  net/netfilter/ipset/ip_set_core.c |  2 +-
>  net/netfilter/nfnetlink.c         | 22 ++++++------
>  net/netlink/af_netlink.c          | 71 ++++++++++++++++++++++++++++++++++-----
>  net/netlink/af_netlink.h          |  1 +
>  net/netlink/genetlink.c           |  3 +-
>  net/xfrm/xfrm_user.c              |  3 +-
>  17 files changed, 153 insertions(+), 34 deletions(-)

Reviewed-by: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
