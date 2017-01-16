From: Robert Shearman <rshearma@brocade.com>
Subject: Re: [PATCH net-next 2/2] mpls: Packet stats
Date: Mon, 16 Jan 2017 10:30:13 +0000
Message-ID: <66948576-787c-b437-7d95-21dea04cbc7d@brocade.com>
References: <201701141417.rz8yuy5o%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <kbuild-all@01.org>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>, roopa <roopa@cumulusnetworks.com>,
        David Ahern <dsa@cumulusnetworks.com>, <ebiederm@xmission.com>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:36050 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751226AbdAPKab (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 05:30:31 -0500
In-Reply-To: <201701141417.rz8yuy5o%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14/01/17 06:41, kbuild test robot wrote:
> Hi Robert,
>
> [auto build test ERROR on net-next/master]
>
> url:    https://urldefense.proofpoint.com/v2/url?u=https-3A__github.com_0day-2Dci_linux_commits_Robert-2DShearman_net-2DAF-2Dspecific-2DRTM-5FGETSTATS-2Dattributes_20170114-2D095819&d=DwIBAg&c=IL_XqQWOjubgfqINi2jTzg&r=HbzsGgI7IidV3zRVGbZOYKAd0w1ch0IRBV2pqme4k9w&m=-FIZAjvyj_cLBHBTW14fNKp5IiJpkr1laQrxgxKnZ3g&s=_d4vequnI_QXJkUb0X3X8AUHdi6qD4R86g-mTBsEJ7g&e=
> config: x86_64-randconfig-u0-01141334 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64
>
> All error/warnings (new ones prefixed by >>):
>
>    In file included from include/net/netns/mib.h:4:0,
>                     from include/net/net_namespace.h:14,
>                     from include/linux/netdevice.h:43,
>                     from include/uapi/linux/if_arp.h:26,
>                     from include/linux/if_arp.h:27,
>                     from net/mpls/af_mpls.c:7:
>    net/mpls/af_mpls.c: In function 'mpls_stats_inc_outucastpkts':
>>> include/net/ipv6.h:163:35: error: 'struct netns_mib' has no member named 'ipv6_statistics'; did you mean 'ip_statistics'?
>      mod##SNMP_UPD_PO_STATS((net)->mib.statname##_statistics, field, (val));\

Good catch kbuild test robot.

Expect to see a v2 shortly with this CONFIG_IPV6=n build failure fixed.

Thanks,
Rob
