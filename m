From: Chris Snook <csnook@redhat.com>
Subject: Re: [PATCH] bonding: fix race that causes invalid statistics
Date: Mon, 28 Jan 2008 19:13:16 -0500
Message-ID: <479E6F9C.90902@redhat.com>
References: <20080128233825.GA21912@gospo.usersys.redhat.com> <23624.1201564743@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:45173 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751646AbYA2ANT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2008 19:13:19 -0500
In-Reply-To: <23624.1201564743@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
> 
>> +	memcpy(stats,&local_stats,sizeof(net_device_stats));
> 
> 	FYI, this generates a compiler error (missing the word "struct"
> in here).  Other than not compiling, the patch seems reasonable.  I'll
> fix it up and include it in the series I'll post tomorrow or so.
> 
> 	-J

Looks like Andy sent the draft version by mistake.  We did in fact test an 
otherwise identical patch, which did fix the bug.

	-- Chris
