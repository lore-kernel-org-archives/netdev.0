From: Andy Zhou <azhou@nicira.com>
Subject: Re: [datapath minor fixes 0/3] datapath minor fixes
Date: Wed, 1 Oct 2014 00:59:51 -0700
Message-ID: <CACzMAJLrHNmiot1R4hupJzXzVQMXNcx9t7OThaZj329Tf7E3sw@mail.gmail.com>
References: <1412150148-9991-1-git-send-email-azhou@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Andy Zhou <azhou@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog138.obsmtp.com ([74.125.149.19]:41550 "HELO
	na3sys009aog138.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751005AbaJAH7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 03:59:51 -0400
Received: by mail-oi0-f43.google.com with SMTP id u20so199242oif.30
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 00:59:51 -0700 (PDT)
In-Reply-To: <1412150148-9991-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please ignore this series. I meant to send them to dev@openvswitch.com.

On Wed, Oct 1, 2014 at 12:55 AM, Andy Zhou <azhou@nicira.com> wrote:
> A few small issues found in preparing for GENEVE support upstreaming
>
> *** BLURB HERE ***
>
> Andy Zhou (3):
>   datapath: avoid hard code OVS_VPORT_TYPE_GENEVE
>   datapath: avoid double free routing entry in vxlan_port xmit
>   datapath: serializing GENEVE options based on flow key's tun_flags
>
>  datapath/flow_netlink.c                           | 2 +-
>  datapath/linux/compat/include/linux/openvswitch.h | 2 +-
>  datapath/vport-vxlan.c                            | 2 --
>  3 files changed, 2 insertions(+), 4 deletions(-)
>
> --
> 1.9.1
>
