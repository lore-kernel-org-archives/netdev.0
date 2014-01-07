From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: question about ixgbevf/ixgbevf_main.c
Date: Tue, 07 Jan 2014 07:55:15 -0800
Message-ID: <52CC2363.1030402@intel.com>
References: <alpine.DEB.2.10.1401071542370.2094@hadrien> <52CC2066.1030303@intel.com> <alpine.DEB.2.10.1401071643340.2094@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: donald.c.skidmore@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:25064 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752071AbaAGPzR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jan 2014 10:55:17 -0500
In-Reply-To: <alpine.DEB.2.10.1401071643340.2094@hadrien>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/07/2014 07:44 AM, Julia Lawall wrote:
> On Tue, 7 Jan 2014, Alexander Duyck wrote:
>
>> A VF isn't a real device so it shouldn't really have the concept of a
>> power state.  The power state for the device is controlled via the PF.
>> I suspect the fact that ixgbevf is modifying power state on resume is
>> likely a bug.
> Thanks for the information, which is very helpful.  Should I submit a
> patch to remove it in the resume function?  I don't have the ability ot
> test it, though.
>
> julia
>

You could submit a patch.  The issue should just be cosmetic.  Setting
the power state to D0 should have no impact on things one way or another
since that is the state VFs are normally in when they are created.

Thanks,

Alex
