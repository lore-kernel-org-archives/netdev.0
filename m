From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 PATCH 1/6 v4] rtnetlink: Netlink interface for
 setting MAC and VLAN filters
Date: Fri, 18 Nov 2011 00:17:01 +0000
Message-ID: <1321575421.2749.53.camel@bwh-desktop>
References: <20111109075449.13549.58135.stgit@rhel6.1>
	 <20111109075540.13549.82297.stgit@rhel6.1>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<chrisw@redhat.com>, <sri@us.ibm.com>, <dragos.tatulea@gmail.com>,
	<kvm@vger.kernel.org>, <arnd@arndb.de>, <mst@redhat.com>,
	<gregory.v.rose@intel.com>, <mchan@broadcom.com>,
	<dwang2@cisco.com>, <shemminger@vyatta.com>,
	<eric.dumazet@gmail.com>, <kaber@trash.net>, <benve@cisco.com>
To: Roopa Prabhu <roprabhu@cisco.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20111109075540.13549.82297.stgit@rhel6.1>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-11-08 at 23:55 -0800, Roopa Prabhu wrote:
> From: Roopa Prabhu <roprabhu@cisco.com>
> 
> This patch introduces the following netlink interface to set
> MAC and VLAN filters on an network interface. It can be used to
> set RX filter on any network interface (if supported by the driver) and
> also on a SRIOV VF via its PF
>
> Interface to set RX filter on a SRIOV VF
> [IFLA_VF_RX_FILTERS] = {
> 	[IFLA_VF_RX_FILTER] = {
> 		[IFLA_RX_FILTER_VF]
> 		[IFLA_RX_FILTER_ADDR] = {
> 			[IFLA_RX_FILTER_ADDR_FLAGS]
> 			[IFLA_RX_FILTER_ADDR_UC_LIST] = {
> 				[IFLA_ADDR_LIST_ENTRY]
> 			}
> 			[IFLA_RX_FILTER_ADDR_MC_LIST] = {
> 				[IFLA_ADDR_LIST_ENTRY]
> 			}
> 		}
> 		[IFLA_RX_FILTER_VLAN] = {
> 			[IFLA_RX_FILTER_VLAN_BITMAP]
> 		}
> 	}
> 	...
> }
[...]

Please put the details of both syntax *and semantics* in if_link.h.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

