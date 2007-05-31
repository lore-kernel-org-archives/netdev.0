From: Divy Le Ray <divy@chelsio.com>
Subject: Re: [PATCH 1/7] cxgb3 - Fix SGE page management
Date: Wed, 30 May 2007 21:10:17 -0700
Message-ID: <465E4AA9.70706@chelsio.com>
References: <20070526225947.12097.82363.stgit@localhost.localdomain> <465B58DE.1010308@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:10271 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753661AbXEaEKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 May 2007 00:10:25 -0400
In-Reply-To: <465B58DE.1010308@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> divy@chelsio.com wrote:
>> From: Divy Le Ray <divy@chelsio.com>
>>
>> Streamline page management on RX.
>> Fix dma mappings.
>>
>
> NAK #2:  You should use the page_address(page) accessor rather than 
> creating a struct member in the same struct as your page, solely to 
> contain the virtual address.
Jeff,

The struct member caches the value of page_address(page) + current 
offset for optimization purposes.

Divy

