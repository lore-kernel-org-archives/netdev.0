From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 00/10] mlxsw: Offload MC flood for unregister
 MC
Date: Fri, 10 Feb 2017 13:12:17 -0500 (EST)
Message-ID: <20170210.131217.414295442645332246.davem@davemloft.net>
References: <1486648489-16455-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, ivecera@redhat.com,
        stephen@networkplumber.org, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44578 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751832AbdBJSU6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 13:20:58 -0500
In-Reply-To: <1486648489-16455-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  9 Feb 2017 14:54:39 +0100

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Nogah says:
> 
> When multicast is enabled, the Linux bridge floods unregistered multicast
> packets only to ports connected to a multicast router. Devices capable of
> offloading the Linux bridge need to be made aware of such ports, for
> proper flooding behavior.
> On the other hand, when multicast is disabled, such packets should be
> flooded to all ports. This patchset aims to fix that, by offloading
> the multicast state and the list of multicast router ports.
> 
> The first 3 patches adds switchdev attributes to offload this data.
> The rest of the patchset add implementation for handling this data in the
> mlxsw driver.
> 
> The effects this data has on the MDB (namely, when the multicast is
> disabled the MDB should be considered as invalid, and when it is enabled, a
> packet that is flooded by it should also be flooded to the multicast
> routers ports) is subject of future work.
> 
> Testing of this patchset included:
> Sending 3 mc packets streams, LL, register and unregistered, and checking
> that they reached only to the ports that should have received them.
> The configs were:
> mc disabled, mc without mc router ports and mc with fixed router port.
> It was checked for vlan aware bridge, vlan unaware bridge and vlan unaware
> bridge with another vlan unaware bridge on the same machine

Series applied, thanks.
