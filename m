From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 0/8] openvswitch: Add vxlan tunneling support.
Date: Thu, 20 Jun 2013 08:58:42 -0700
Message-ID: <20130620085842.27a588d2@nehalam.linuxnetplumber.net>
References: <1371713175-8037-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:32777 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757896Ab3FTP6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 11:58:46 -0400
Received: by mail-pd0-f175.google.com with SMTP id 4so6392852pdd.20
        for <netdev@vger.kernel.org>; Thu, 20 Jun 2013 08:58:45 -0700 (PDT)
In-Reply-To: <1371713175-8037-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Jun 2013 00:26:15 -0700
Pravin B Shelar <pshelar@nicira.com> wrote:

> First two patches fixes vxlan issues.  Next two patches
> extends vxlan so that openvswitch can share vxlan udp port
> with vxlan module. Rest of patches refactors vxlan data
> plane so that ovs can share that code with vxlan module.
> Last patch adds vxlan-vport to openvswitch.
> 
> Pravin B Shelar (8):
>   vxlan: Fix error handling while creating device.
>   vxlan: Fix sparse wornings.
>   vxlan: Allow multiple recieve handlers.
>   vxlan: Extend vxlan handlers for openvswitch.
>   vxlan: Factor out vxlan send api.
>   vxlan: Improve vxlan headroom calculation.
>   vxlan: Add tx-vlan offload support.
>   openvswitch: Add vxlan tunneling support.
> 
>  drivers/net/vxlan.c              |  337 +++++++++++++++++++++++++-------------
>  include/net/vxlan.h              |   33 ++++
>  include/uapi/linux/openvswitch.h |   11 ++
>  net/openvswitch/Kconfig          |    1 +
>  net/openvswitch/Makefile         |    3 +-
>  net/openvswitch/vport-vxlan.c    |  220 +++++++++++++++++++++++++
>  net/openvswitch/vport.c          |    3 +
>  net/openvswitch/vport.h          |    1 +
>  8 files changed, 490 insertions(+), 119 deletions(-)
>  create mode 100644 include/net/vxlan.h
>  create mode 100644 net/openvswitch/vport-vxlan.c

I will merge the first 7 into my vxlan repository and send a pull request.
