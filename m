From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] ixgbe: Fix for RAR0 not being set to default
 MAC addr
Date: Wed, 6 Jan 2016 15:48:46 -0500
Message-ID: <20160106204846.GE23622@oracle.com>
References: <1452110729-15659-1-git-send-email-tushar.n.dave@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jesse.brandeburg@intel.com, john.ronciak@intel.com,
	donald.c.skidmore@intel.com, carolyn.wyborny@intel.com,
	netdev@vger.kernel.org, duyck@mirantis.com, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org
To: Tushar Dave <tushar.n.dave@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:20001 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751708AbcAFUtC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 15:49:02 -0500
Content-Disposition: inline
In-Reply-To: <1452110729-15659-1-git-send-email-tushar.n.dave@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/06/16 12:05), Tushar Dave wrote:

> commit c9f53e63c208 ("ixgbe: Refactor MAC address configuration code")
> introduced code that doesn't set HW register RAR0 to default mac address
> but FF:FF:FF:FF:FF:FF. Due to this, ixgbe HW discards all incoming packets
> that doesn't have destination mac address equals to FF:FF:FF:FF:FF:FF.
> 
> This commit sets RAR0 correctly to default HW mac address.
> 
> Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>

Tested-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
