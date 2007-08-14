From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 5/13] cxgb3 - Expose HW memory page info
Date: Tue, 14 Aug 2007 16:27:47 -0700
Message-ID: <46C23A73.4090907@chelsio.com>
References: <20070811062954.8094.33064.stgit@speedy5> <46C14140.2000104@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:7241 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935110AbXHNX1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 19:27:52 -0400
In-Reply-To: <46C14140.2000104@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Divy Le Ray wrote:
>> From: Divy Le Ray <divy@chelsio.com>
>>
>> Let the RDMA driver get HW page info to work around HW issues.
>> Assign explicit enum values.
>>
>> Signed-off-by: Divy Le Ray <divy@chelsio.com>
>
> "HW issues" -- you need to go into far more detail, when adding a new 
> interface.  what hw issues?  why was this the best/only solution?
>
>

A HW issue requires limiting the receive window size to 23 pages of 
internal memory.
These pages can be configured to different sizes, thus the RDMA driver 
needs to know the
page size to enforce the upper limit.

Divy
