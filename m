From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [rfc 0/4] igb: bandwidth allocation
Date: Thu, 05 Nov 2009 13:09:44 +0100
Message-ID: <87bpjh896f.fsf@basil.nowhere.org>
References: <20091105005847.941190065@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Arnd Bergmann <arndbergmann@googlemail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:46898 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755174AbZKEMJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 07:09:42 -0500
In-Reply-To: <20091105005847.941190065@vergenet.net> (Simon Horman's message of "Thu, 05 Nov 2009 11:58:47 +1100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simon Horman <horms@verge.net.au> writes:

> Hi,
>
> this series of patches exposes the bandwidth allocation
> hardware support of the Intel 82576. It does so through
> a rather hackish sysfs entry. That interface is just intended
> for testing so that the exposed hardware feature can
> be exercised. I would like to find a generic way to expose
> this feature to user-space.

It would be cool if you had a interface that did a software
fallback for NICs that don't support this.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
