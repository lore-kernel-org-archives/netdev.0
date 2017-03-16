From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v3 0/9] mlxsw: Enable VRF offload
Date: Thu, 16 Mar 2017 10:20:22 -0700 (PDT)
Message-ID: <20170316.102022.1371204829896380177.davem@davemloft.net>
References: <1489651700-3586-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com,
        dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, lorenzo@google.com, mateusz.bajorski@nokia.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37080 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751185AbdCPRVg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 13:21:36 -0400
In-Reply-To: <1489651700-3586-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 16 Mar 2017 09:08:11 +0100

> Packets received from netdevs enslaved to different VRF devices are
> forwarded using different FIB tables. In the Spectrum ASIC this is
> achieved by binding different router interfaces (RIFs) to different
> virtual routers (VRs). Each RIF represents an enslaved netdev and each
> VR has its own FIB table according to which packets are forwarded.
> 
> The first three patches add an helper to check if a FIB rule is a
> default rule and extend the FIB notification chain to include the rule's
> info as part of the RULE_{ADD,DEL} events. This allows offloading
> drivers to sanitize the rules they don't support and flush their tables.
> 
> The fourth patch introduces a small change in the VRF driver to allow
> capable drivers to more easily offload VRFs.
> 
> Finally, the last patches gradually add support for VRFs in the mlxsw
> driver. First, on top of port netdevs, stacked LAG and VLAN devices and
> then on top of bridges.

Series applied, thanks.
