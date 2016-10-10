From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip link: Add support to configure SR-IOV VF to
 vlan protocol 802.1ad (VST QinQ)
Date: Sun, 9 Oct 2016 19:24:34 -0700
Message-ID: <20161009192434.04902ca0@xeon-e3>
References: <1475049539-25905-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Moshe Shemesh <moshe@mellanox.com>
To: Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36694 "EHLO
        mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbcJJCYU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2016 22:24:20 -0400
Received: by mail-pa0-f50.google.com with SMTP id ry6so45918380pac.3
        for <netdev@vger.kernel.org>; Sun, 09 Oct 2016 19:24:19 -0700 (PDT)
In-Reply-To: <1475049539-25905-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Sep 2016 10:58:59 +0300
Tariq Toukan <tariqt@mellanox.com> wrote:

> From: Moshe Shemesh <moshe@mellanox.com>
> 
> Introduce a new API that exposes a list of vlans per VF (IFLA_VF_VLAN_LIST),
> giving the ability for user-space application to specify it for the VF as
> an option to support 802.1ad (VST QinQ).
> 
> We introduce struct vf_vlan_info, which extends struct vf_vlan and adds
> an optional VF VLAN proto parameter.
> Default VLAN-protocol is 802.1Q.
> 
> Add IFLA_VF_VLAN_LIST in addition to IFLA_VF_VLAN to keep backward
> compatibility with older kernel versions.
> 
> Suitable ip link tool command examples:
>  - Set vf vlan protocol 802.1ad (S-TAG)
> 	ip link set eth0 vf 1 vlan 100 proto 802.1ad
>  - Set vf vlan S-TAG and vlan C-TAG (VST QinQ)
> 	ip link set eth0 vf 1 vlan 100 proto 802.1ad vlan 30 proto 802.1Q
>  - Set vf to VST (802.1Q) mode
> 	ip link set eth0 vf 1 vlan 100 proto 802.1Q
>  - Or by omitting the new parameter (backward compatible)
> 	ip link set eth0 vf 1 vlan 100
> 
> Signed-off-by: Moshe Shemesh <moshe@mellanox.com>
> Signed-off-by: Tariq Toukan <tariqt@mellanox.com>

Applied to net-next (for 4.9)
