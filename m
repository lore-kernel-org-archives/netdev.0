From: Loic Prylli <loic@myri.com>
Subject: Re: howto use ioremap_wc?
Date: Mon, 02 Jun 2008 14:18:04 -0400
Message-ID: <4844395C.2010900@myri.com>
References: <4841143E.5080003@myri.com> <20080531185424.1cd18220@infradead.org> <48441F73.5040005@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@infradead.org>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	"venkatesh.pallipadi@intel.com" <venkatesh.pallipadi@intel.com>
To: Brice Goglin <brice@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:2004 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751602AbYFBSqb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2008 14:46:31 -0400
In-Reply-To: <48441F73.5040005@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/02/2008 12:27 PM, Brice Goglin wrote:
> Arjan van de Ven wrote:
>   
>> Ok this leads to a question: since write combining is effectively an
>> extension (eg relaxation) to uncached, how much do you care if you
>> actually get uncached? Eg can you just use the "WC" function even for
>> the case where you get an uncached mapping ?
>>   
>>     
>
> WC is strictly required for our "wcfifo" path,




To be more accurate about the above statement, that codepath will still 
work correctly even if the mapping ends-up being uncached, but that 
could lead to a 16X slowdown on some machines, since that path was 
really designed for the WC case.


Anyway that codepath does not really matter as Brice mentioned 
afterwards :-)



>  but this path is actually
> not so important nowadays. It is disabled by default and might even be
> removed in the future. So, no, myri10ge itself does not really need to
> know whether the mapping is actually WC.
>   




Loic

