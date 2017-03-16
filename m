From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] openvswitch: Add missing case
 OVS_TUNNEL_KEY_ATTR_PAD
Date: Thu, 16 Mar 2017 12:00:28 -0700 (PDT)
Message-ID: <20170316.120028.1195095010958027326.davem@davemloft.net>
References: <1b8ba07efdee3db310d4504462924565684ebd64.1489677257.git.kriskend@linux.vnet.ibm.com>
        <1489679488-18874-1-git-send-email-kriskend@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, seroyer@linux.vnet.ibm.com,
        adreznec@linux.vnet.ibm.com
To: kriskend@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41300 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752014AbdCPTJs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 15:09:48 -0400
In-Reply-To: <1489679488-18874-1-git-send-email-kriskend@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kris Murphy <kriskend@linux.vnet.ibm.com>
Date: Thu, 16 Mar 2017 10:51:28 -0500

> Added a case for OVS_TUNNEL_KEY_ATTR_PAD to the switch statement
> in ip_tun_from_nlattr in order to prevent the default case
> returning an error.
> 
> Fixes: b46f6ded906e ("libnl: nla_put_be64(): align on a 64-bit area")
> Signed-off-by: Kris Murphy <kriskend@linux.vnet.ibm.com>

Applied and queued up for -stable, thanks.
