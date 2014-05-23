From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH] net: Add support for device specific address syncing
Date: Fri, 23 May 2014 12:33:20 -0700
Message-ID: <537FA280.7040607@intel.com>
References: <20140521205457.31151.8273.stgit@ahduyck-cp2.jf.intel.com> <20140523.145535.35857476092197009.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	jpirko@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:48201 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750995AbaEWTdV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 May 2014 15:33:21 -0400
In-Reply-To: <20140523.145535.35857476092197009.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/23/2014 11:55 AM, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> Date: Wed, 21 May 2014 13:55:15 -0700
> 
>> This change provides a function to be used in order to break the
>> ndo_set_rx_mode call into a set of address add and remove calls.  The code
>> is based on the implementation of dev_uc_sync/dev_mc_sync.  Since they
>> essentially do the same thing but with only one dev I simply named my
>> functions __dev_uc_sync/__dev_mc_sync.
>>
>> I also implemented an unsync version of the functions as well to allow for
>> cleanup on close.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This looks fine semantically to me.
> 
> Please fix the coding style issues below and submit this alongside
> the changes for whatever driver will first make use of this.
> 
> Thanks!

Okay.  Will do.

Thanks,

Alex
