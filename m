From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 0/3] Retrieve number of VFs in a bus-agnostic
 way
Date: Fri, 20 Jan 2017 11:43:46 -0500 (EST)
Message-ID: <20170120.114346.786441265338417344.davem@davemloft.net>
References: <20170118130439.15023-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhelgaas@google.com, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33076 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752780AbdATQns (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 11:43:48 -0500
In-Reply-To: <20170118130439.15023-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Wed, 18 Jan 2017 14:04:36 +0100

> Previously, it was assumed that only PCI NICs would be capable of having
> virtual functions - with my proposed enhancement of dummy NIC driver
> implementing (fake) ones for testing purposes, this is no longer true.
> 
> Discussion of said patch has led to the suggestion of implementing a
> bus-agnostic method for VF count retrieval so rtnetlink could work with
> both real VF-capable PCI NICs as well as my dummy modifications without
> introducing ugly hacks.
> 
> The following series tries to achieve just that by introducing a bus
> type callback to retrieve a device's number of VFs, implementing this
> callback for PCI bus and finally adjusting rtnetlink to make use of the
> generalized infrastructure.

This is really nice and clean, compare it to your original approach :-)

Series applied, thanks!
