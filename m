From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [PATCH nf-next v8 8/8] openvswitch: Interface with NAT.
Date: Wed, 9 Mar 2016 15:11:17 -0800
Message-ID: <17C47A83-FF01-4D09-AF32-A66D4C9D2C0F@ovn.org>
References: <201603091647.Hv6Rrs7K%fengguang.wu@intel.com>
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>, ovs dev <dev@openvswitch.org>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <201603091647.Hv6Rrs7K%fengguang.wu@intel.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just sent a v9 addressing these dependency issues.

  Jarno

> On Mar 9, 2016, at 12:04 AM, kbuild test robot <lkp@intel.com> wrote:
> 
> Hi Jarno,
> 
> [auto build test ERROR on nf-next/master]
> 
> url:    https://github.com/0day-ci/linux/commits/Jarno-Rajahalme/netfilter-Remove-IP_CT_NEW_REPLY-definition/20160309-083126
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next master
> config: i386-randconfig-x0-03091344 (attached as .config)
> reproduce:
>        # save the attached .config to linux build tree
>        make ARCH=i386 
> 
> All errors (new ones prefixed by >>):
> 
>   net/built-in.o: In function `__ovs_ct_lookup':
>>> conntrack.c:(.text+0x227267): undefined reference to `nf_ct_nat_ext_add'
>>> conntrack.c:(.text+0x227404): undefined reference to `nf_nat_icmp_reply_translation'
>   conntrack.c:(.text+0x2274ab): undefined reference to `nf_nat_icmpv6_reply_translation'
>>> conntrack.c:(.text+0x227585): undefined reference to `nf_nat_setup_info'
>>> conntrack.c:(.text+0x2275a1): undefined reference to `nf_nat_alloc_null_binding'
>>> conntrack.c:(.text+0x2275d2): undefined reference to `nf_nat_packet'
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> <.config.gz>

