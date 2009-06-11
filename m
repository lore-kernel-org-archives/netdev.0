From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 1/6] rapidio: add common mapping APIs for RapidIO memory access
Date: Thu, 11 Jun 2009 08:32:24 -0500
Message-ID: <5D8775BD-9973-4DE8-B442-91FB15F86ACC@kernel.crashing.org>
References: <1242117363-14949-1-git-send-email-leoli@freescale.com> <90AED712-28A1-4800-978C-125A887D0DA7@kernel.crashing.org> <3A45394FD742FA419B760BB8D398F9ED483CCD@zch01exm26.fsl.freescale.net>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: <akpm@linux-foundation.org>, <davem@davemloft.net>,
	<mporter@kernel.crashing.org>, <linux-kernel@vger.kernel.org>,
	<linuxppc-dev@ozlabs.org>, <netdev@vger.kernel.org>,
	"Zhang Wei" <zw@zh-kernel.org>
To: Li Yang-R58472 <LeoLi@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:57809 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751708AbZFKNei (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 09:34:38 -0400
In-Reply-To: <3A45394FD742FA419B760BB8D398F9ED483CCD@zch01exm26.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jun 11, 2009, at 4:47 AM, Li Yang-R58472 wrote:

>> On May 12, 2009, at 3:35 AM, Li Yang wrote:
>>
>>> Add the mapping functions used to support direct IO memory access of
>>> rapidIO.
>>>
>>> Signed-off-by: Zhang Wei <zw@zh-kernel.org>
>>> Signed-off-by: Li Yang <leoli@freescale.com>
>>
>> Use inbnd/outbnd instead of inb/outb which make one think of
>> byte level io accessors.
>>
>> As I look at this I don't think this is the correct API.  I
>> think we should be using the DMA mapping API to hide these
>> details.  The concept of mapping like this seems to be more a
>> function of FSL's Address translation/mapping unit (ATMU) than
>> anything specific to the RIO bus standard.
>
> This is a separate RIO block level ATMU.  Although it looks like the
> system level ATMU, system ATMU doesn't have the knowledge of rapidIO
> target device ID.  The mapping need to be dynamic, as it's easy to  
> have
> more RIO devices than the outbound windows.

I understand that.  What I'm saying is the RIO block level ATMU is a  
Freescale specific detail and not part of any standard RIO bus  
programming model.  We have mapping APIs that we can connect to for  
this via the DMA API layer.

- k
