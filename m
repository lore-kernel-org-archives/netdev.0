From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [patch net-next v3 0/9] sched: introduce vlan action
Date: Tue, 18 Nov 2014 23:54:05 +0200
Message-ID: <CAJ3xEMhX0RnykPKJ3VHdn8oez=RHnOWTOFpRaMEYJtr96_AMNA@mail.gmail.com>
References: <1416346664-9290-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Pravin Shelar <pshelar@nicira.com>,
	Tom Herbert <therbert@google.com>,
	Eric Dumazet <edumazet@google.com>, willemb@google.com,
	Daniel Borkmann <dborkman@redhat.com>,
	"Michael S. Tsirkin <mst@redhat.com> (mst@redhat.com)"
	<mst@redhat.com>, Florian Westphal <fw@strlen.de>,
	Paul.Durrant@citrix.com, Thomas Graf <tgraf@suug.ch>,
	Cong Wang <cwang@twopensource.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:38018 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755256AbaKRVyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 16:54:05 -0500
Received: by mail-ob0-f178.google.com with SMTP id gq1so4773638obb.37
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 13:54:05 -0800 (PST)
In-Reply-To: <1416346664-9290-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 18, 2014 at 11:37 PM, Jiri Pirko <jiri@resnulli.us> wrote:

Hi Jiri (WB from your vacation),

Sorry for the a bit of cold shower, but empty cover letter and no sign for

V2 --> V3
[...]

V1 --> V2
[...]

V0 --> V1
[...]


tracking in the 0/N patch, doesn't allow for proper review, I would say...

Or.

> Jiri Pirko (9):
>   openvswitch: actions: use skb_postpull_rcsum when possible
>   vlan: make __vlan_hwaccel_put_tag return void
>   vlan: kill vlan_put_tag helper
>   vlan: rename __vlan_put_tag to vlan_insert_tag_set_proto
>   vlan: introduce *vlan_hwaccel_push_inside helpers
>   vlan: introduce __vlan_insert_tag helper which does not free skb
>   net: move make_writable helper into common code
>   net: move vlan pop/push functions into common code
>   sched: introduce vlan action
>
>  drivers/net/bonding/bond_alb.c              |  17 +--
>  drivers/net/bonding/bond_main.c             |  12 +-
>  drivers/net/ethernet/emulex/benet/be_main.c |   6 +-
>  drivers/net/usb/cdc_mbim.c                  |   2 +-
>  drivers/net/vxlan.c                         |  22 +--
>  drivers/scsi/fcoe/fcoe.c                    |   6 +-
>  include/linux/if_vlan.h                     | 107 +++++++++-----
>  include/linux/skbuff.h                      |   3 +
>  include/net/tc_act/tc_vlan.h                |  27 ++++
>  include/uapi/linux/tc_act/tc_vlan.h         |  35 +++++
>  net/8021q/vlan_dev.c                        |   2 +-
>  net/bridge/br_vlan.c                        |   4 +-
>  net/core/dev.c                              |   8 +-
>  net/core/netpoll.c                          |   4 +-
>  net/core/skbuff.c                           | 107 ++++++++++++++
>  net/ipv4/geneve.c                           |  12 +-
>  net/openvswitch/actions.c                   | 130 ++++-------------
>  net/openvswitch/datapath.c                  |   5 +-
>  net/openvswitch/vport-gre.c                 |  12 +-
>  net/sched/Kconfig                           |  11 ++
>  net/sched/Makefile                          |   1 +
>  net/sched/act_vlan.c                        | 207 ++++++++++++++++++++++++++++
>  22 files changed, 525 insertions(+), 215 deletions(-)
>  create mode 100644 include/net/tc_act/tc_vlan.h
>  create mode 100644 include/uapi/linux/tc_act/tc_vlan.h
>  create mode 100644 net/sched/act_vlan.c
>
> --
> 1.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
