From: "Li Yang-R58472" <LeoLi@freescale.com>
Subject: RE: [PATCH 1/6] rapidio: add common mapping APIs for RapidIO memory access
Date: Thu, 11 Jun 2009 17:47:56 +0800
Message-ID: <3A45394FD742FA419B760BB8D398F9ED483CCD@zch01exm26.fsl.freescale.net>
References: <1242117363-14949-1-git-send-email-leoli@freescale.com> <90AED712-28A1-4800-978C-125A887D0DA7@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <akpm@linux-foundation.org>, <davem@davemloft.net>,
	<mporter@kernel.crashing.org>, <linux-kernel@vger.kernel.org>,
	<linuxppc-dev@ozlabs.org>, <netdev@vger.kernel.org>,
	"Zhang Wei" <zw@zh-kernel.org>
To: "Kumar Gala" <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:63514 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761298AbZFKJsO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 05:48:14 -0400
Content-class: urn:content-classes:message
In-Reply-To: <90AED712-28A1-4800-978C-125A887D0DA7@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>On May 12, 2009, at 3:35 AM, Li Yang wrote:
>
>> Add the mapping functions used to support direct IO memory access of 
>> rapidIO.
>>
>> Signed-off-by: Zhang Wei <zw@zh-kernel.org>
>> Signed-off-by: Li Yang <leoli@freescale.com>
>
>Use inbnd/outbnd instead of inb/outb which make one think of 
>byte level io accessors.
>
>As I look at this I don't think this is the correct API.  I 
>think we should be using the DMA mapping API to hide these 
>details.  The concept of mapping like this seems to be more a 
>function of FSL's Address translation/mapping unit (ATMU) than 
>anything specific to the RIO bus standard.

This is a separate RIO block level ATMU.  Although it looks like the
system level ATMU, system ATMU doesn't have the knowledge of rapidIO
target device ID.  The mapping need to be dynamic, as it's easy to have
more RIO devices than the outbound windows.

- Leo
