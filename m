From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH 4/4] bonding: fix multiple 3ad mode sysfs race conditions
Date: Sat, 18 May 2013 04:45:00 +0200
Message-ID: <5196EB2C.1040607@redhat.com>
References: <1368621162-6807-1-git-send-email-nikolay@redhat.com> <1368621162-6807-5-git-send-email-nikolay@redhat.com> <30362.1368809999@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42928 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755352Ab3ERCpz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 May 2013 22:45:55 -0400
In-Reply-To: <30362.1368809999@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17/05/13 18:59, Jay Vosburgh wrote:
>
> 	I think the patch is functionally fine, but the usual
> nomenclature for adding a "wrapper" is to have the "functional" piece be
> named "__function", and the "wrapper" piece to be just "function".  In
> this case, it would be __bond_3ad_get_active_agg_info for the "inside"
> function (the current function that is being wrapped), and
> bond_3ad_get_active_agg_info for the wrapper.  Yes, this makes for a
> different changeset (as some other calls already hold the locks and will
> change to the __ version), but the end result is clearer.
> 
> 	-J
> 

Jay thank you for the review, I've done the necessary changes to the
function names and moved the wrapper to bond_3ad.c, but had to make them
both global as you said since they're both used at different places.
I'll re-post v2 tomorrow after I do some testing since it's 4 am here
now :-)

Cheers,
 Nik
