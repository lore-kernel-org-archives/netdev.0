From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [patch net-next v3 02/17] net: make vid as a parameter for ndo_fdb_add/ndo_fdb_del
Date: Tue, 25 Nov 2014 10:53:17 -0800
Message-ID: <5474D01D.2020605@intel.com>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us> <1416911328-10979-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:41075 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750896AbaKYSxT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Nov 2014 13:53:19 -0500
In-Reply-To: <1416911328-10979-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 11/25/2014 2:28 AM, Jiri Pirko wrote:
> Do the work of parsing NDA_VLAN directly in rtnetlink code, pass simple
> u16 vid to drivers from there.
>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
> new in v3
> ---
>   drivers/net/ethernet/intel/i40e/i40e_main.c      |  2 +-
>   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  4 +-
>   drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |  9 +++--
>   drivers/net/macvlan.c                            |  4 +-
>   drivers/net/vxlan.c                              |  4 +-
>   include/linux/netdevice.h                        |  8 ++--
>   include/linux/rtnetlink.h                        |  6 ++-
>   net/bridge/br_fdb.c                              | 39 ++----------------
>   net/bridge/br_private.h                          |  4 +-
>   net/core/rtnetlink.c                             | 50 ++++++++++++++++++++----
>   10 files changed, 70 insertions(+), 60 deletions(-)
>
<deleted>
>   
> +static int fbd_vid_parse(struct nlattr *vlan_attr, u16 *p_vid)

looks like a typo? fdb_vid_parse()
