From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] i40evf: Rename i40e_ptype_lookup i40evf_ptype_lookup
Date: Tue, 18 Mar 2014 13:26:43 -0400 (EDT)
Message-ID: <20140318.132643.599932107562895578.davem@davemloft.net>
References: <1395127610-3290-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, jesse.brandeburg@intel.com,
	catherine.sullivan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53625 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757325AbaCRR0q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 13:26:46 -0400
In-Reply-To: <1395127610-3290-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 18 Mar 2014 00:26:50 -0700

> From: Eric W Biederman <ebiederm@xmission.com>
> 
> When compiling the i40e and the i40evf driver into the same kernel I get:
> LD      drivers/net/ethernet/intel/built-in.o
> drivers/net/ethernet/intel/i40evf/built-in.o:(.data+0x300): multiple definition of `i40e_ptype_lookup'
> drivers/net/ethernet/intel/i40e/built-in.o:(.data+0x780): first defined here
> make[3]: *** [drivers/net/ethernet/intel/built-in.o] Error 1
> make[2]: *** [drivers/net/ethernet/intel] Error 2
> make[1]: *** [drivers/net/ethernet/] Error 2
> make: *** [sub-make] Error 2
> 
> Fix this by renaming the i40evf version of this structure from
> i40e_ptype_lookup to i40evf_ptype_lookup.
> 
> This build failure was introduced in:
>   commit 206812b5fccb808d1194344eaa942f68f59b2630
>   Author: Jesse Brandeburg <jesse.brandeburg@intel.com>
>   i40e/i40evf: i40e implementation for skb_set_hash
> 
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Catherine Sullivan <catherine.sullivan@intel.com>
> Signed-off-by: Eric W Biederman <ebiederm@xmission.com>
> Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
