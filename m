From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH][BONDING] Add max_bonds kernel parameter
Date: Fri, 29 Feb 2008 11:03:56 -0800
Message-ID: <4405.1204311836@death>
References: <20080229185130.GA28138@linuxace.com>
Cc: netdev@vger.kernel.org
To: Phil Oester <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:44720 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758688AbYB2TE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 14:04:26 -0500
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1TJ4Qs3006207
	for <netdev@vger.kernel.org>; Fri, 29 Feb 2008 14:04:26 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1TJ4CPJ128844
	for <netdev@vger.kernel.org>; Fri, 29 Feb 2008 12:04:17 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1TJ42LN000970
	for <netdev@vger.kernel.org>; Fri, 29 Feb 2008 12:04:03 -0700
In-reply-to: <20080229185130.GA28138@linuxace.com> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Phil Oester <kernel@linuxace.com> wrote:
[...]
>    The bonding driver (and initscripts) seem to assume everyone loads bonding
>    as a module.  So when compiled into the kernel, changing the max_bonds
>    parameter can only be done in the source code.

	The kernel should already handle options for compiled-in
modules.  For bonding, you'd put something like "bonding.max_bonds=3" on
the kernel boot line.  No need to patch bonding for this.  This is
described in Documentation/kernel-parameters.txt (right at the top).

	On your other patch, I don't see a big issue with allowing
max_bonds to be zero; I'll have a look at the details and test it out.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
