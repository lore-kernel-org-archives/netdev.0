From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v6 1/3] net: add NSH header structures and
 helpers
Date: Fri, 25 Aug 2017 17:07:49 +0200
Message-ID: <20170825170749.53e49285@griffin>
References: <1503670805-31051-1-git-send-email-yi.y.yang@intel.com>
        <1503670805-31051-2-git-send-email-yi.y.yang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org, e@erig.me,
        blp@ovn.org, jan.scheurich@ericsson.com
To: Yi Yang <yi.y.yang@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45664 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933145AbdHYPHy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Aug 2017 11:07:54 -0400
In-Reply-To: <1503670805-31051-2-git-send-email-yi.y.yang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Aug 2017 22:20:03 +0800, Yi Yang wrote:
> --- a/include/uapi/linux/if_ether.h
> +++ b/include/uapi/linux/if_ether.h
> @@ -138,6 +138,7 @@
>  #define ETH_P_IEEE802154 0x00F6		/* IEEE802.15.4 frame		*/
>  #define ETH_P_CAIF	0x00F7		/* ST-Ericsson CAIF protocol	*/
>  #define ETH_P_XDSA	0x00F8		/* Multiplexed DSA protocol	*/
> +#define ETH_P_NSH	0x894F		/* Ethertype for NSH. */

This is in a wrong section. It belongs to Ethernet protocols a few lines
higher in the file (after ETH_P_HSR).

 Jiri
