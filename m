From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 V2 0/2] tc: flower, m_vlan: Introduce vlan tag
 support
Date: Thu, 1 Sep 2016 08:40:29 -0700
Message-ID: <20160901084029.7b466f16@xeon-e3>
References: <1472712348-1415-1-git-send-email-hadarh@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>
To: Hadar Hen Zion <hadarh@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33207 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754737AbcIAPkU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 11:40:20 -0400
Received: by mail-pf0-f173.google.com with SMTP id g202so9411267pfb.0
        for <netdev@vger.kernel.org>; Thu, 01 Sep 2016 08:40:20 -0700 (PDT)
In-Reply-To: <1472712348-1415-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  1 Sep 2016 09:45:46 +0300
Hadar Hen Zion <hadarh@mellanox.com> wrote:

> Hi,
> 
> This patchset introduce vlan tag support to the tc flower classifier.
> In addition to adding vlan priority to vlan push action.
> 
> - The first patch adds classification according to vlan id and vlan priority to the flower.
> - The second patch adds support for vlan priority to the current vlan push action.
> 
> Changes from v1:
> - Remove VLAN_PRIO_MASK and VLAN_VID_MASK defines from tc_vlan.h file
> 
> 
> Hadar Hen Zion (2):
>   tc: flower: Introduce vlan support
>   tc: m_vlan: Add priority option to push vlan action
> 
>  man/man8/tc-flower.8 | 25 ++++++++++++++++-
>  man/man8/tc-vlan.8   |  5 ++++
>  tc/f_flower.c        | 78 ++++++++++++++++++++++++++++++++++++++++++++++++++--
>  tc/m_vlan.c          | 22 ++++++++++++++-
>  4 files changed, 125 insertions(+), 5 deletions(-)
> 

Applied to net-next
