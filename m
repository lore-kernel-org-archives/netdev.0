From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 2.6.21 3/4] cxgb3 - Fix potential MAC hang
Date: Wed, 21 Mar 2007 18:06:41 -0800
Message-ID: <4601E4B1.2000205@chelsio.com>
References: <20070318201011.16310.77866.stgit@localhost.localdomain> <20070321150748.2abf2bd5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:27658 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753118AbXCVCGy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2007 22:06:54 -0400
In-Reply-To: <20070321150748.2abf2bd5.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Sun, 18 Mar 2007 13:10:12 -0700
> divy@chelsio.com wrote:
>
>   
>> From: Divy Le Ray <divy@chelsio.com>
>>
>> Under rare conditions, the MAC might hang while generating a pause frame.
>> This patch fine tunes the MAC settings to avoid the issue, allows for 
>> periodic MAC state check, and triggers a recovery if hung. 
>>
>> Also fix one MAC statistics counter for the rev board T3B2.
>>     
>
> This conflicts with your previously-submitted, not-yet-merged-by-Jeff
> cxgb3-add-sw-lro-support.patch.
>
> What should we do about this?
>   

I can send you a patch against the -mm tree, if it is acceptable.

Cheers,
Divy

