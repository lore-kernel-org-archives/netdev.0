From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH net-next 1/1 v2] net: rmnet_data: Initial implementation
Date: Tue, 14 Mar 2017 06:24:32 +0800
Message-ID: <201703140606.1NyT5yR4%fengguang.wu@intel.com>
References: <1489390989-2408-2-git-send-email-subashab@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org, davem@davemloft.net,
        fengguang.wu@intel.com,
        Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
To: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:35063 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752553AbdCMWZ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Mar 2017 18:25:27 -0400
Content-Disposition: inline
In-Reply-To: <1489390989-2408-2-git-send-email-subashab@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Subash,

[auto build test WARNING on net-next/master]

url:    https://github.com/0day-ci/linux/commits/Subash-Abhinov-Kasiviswanathan/net-rmnet_data-Initial-implementation/20170313-174754
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   include/linux/compiler.h:264:8: sparse: attribute 'no_sanitize_address': unknown attribute
>> include/uapi/linux/rmnet_data.h:46:25: sparse: invalid bitfield specifier for type restricted __le16.
   include/uapi/linux/rmnet_data.h:47:19: sparse: invalid bitfield specifier for type restricted __le16.

vim +46 include/uapi/linux/rmnet_data.h

    30	#define RMNET_EGRESS_FORMAT_AGGREGATION         (1<<2)
    31	#define RMNET_EGRESS_FORMAT_MUXING              (1<<3)
    32	#define RMNET_EGRESS_FORMAT_MAP_CKSUMV3         (1<<4)
    33	#define RMNET_EGRESS_FORMAT_MAP_CKSUMV4         (1<<5)
    34	
    35	#define RMNET_INGRESS_FIX_ETHERNET              (1<<0)
    36	#define RMNET_INGRESS_FORMAT_MAP                (1<<1)
    37	#define RMNET_INGRESS_FORMAT_DEAGGREGATION      (1<<2)
    38	#define RMNET_INGRESS_FORMAT_DEMUXING           (1<<3)
    39	#define RMNET_INGRESS_FORMAT_MAP_COMMANDS       (1<<4)
    40	#define RMNET_INGRESS_FORMAT_MAP_CKSUMV3        (1<<5)
    41	#define RMNET_INGRESS_FORMAT_MAP_CKSUMV4        (1<<6)
    42	
    43	struct rmnet_nl_msg_s {
    44		__le16 reserved;
    45		__le16 message_type;
  > 46		__le16 reserved2:14;
    47		__le16 crd:2;
    48		union {
    49			__le16 arg_length;
    50			__le16 return_code;
    51		};
    52		union {
    53			__u8 data[RMNET_NL_DATA_MAX_LEN];
    54			struct {

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
