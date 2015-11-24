From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 04/15] ixgbe: Delete redundant include file
Date: Tue, 24 Nov 2015 10:36:14 -0800
Message-ID: <1448390174.20113.10.camel@perches.com>
References: <1448307376-20063-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1448307376-20063-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0011.hostedemail.com ([216.40.44.11]:36615 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754943AbbKXSgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 13:36:18 -0500
In-Reply-To: <1448307376-20063-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-11-23 at 11:36 -0800, Jeff Kirsher wrote:
> Delete a redundant include of net/vxlan.h.

unrelated trivia:

> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
[]
>  char ixgbe_driver_name[] = "ixgbe";

This could be const or a #define
