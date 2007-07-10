From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/1] ixgbe: Support for Intel(R) 10GbE PCI Express adapters
 -	Take #2
Date: Tue, 10 Jul 2007 14:23:41 -0400
Message-ID: <4693CEAD.5050900@garzik.org>
References: <E35F4F4D7F6C9E4E826FEC1F86CEF583042488B2@orsmsx412.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arjan@linux.intel.com,
	akpm@linux-foundation.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, hch@infradead.org,
	shemminger@linux-foundation.org, nhorman@tuxdriver.com,
	inaky@linux.intel.com, mb@bu3sch.de
To: "Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33007 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760560AbXGJSXo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 14:23:44 -0400
In-Reply-To: <E35F4F4D7F6C9E4E826FEC1F86CEF583042488B2@orsmsx412.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Veeraiyan, Ayyappan wrote:
> On 7/10/07, Jeff Garzik <jeff@garzik.org> wrote:
>> Ayyappan.Veeraiyan@intel.com wrote:
>>
>> Doing both tends to signal that the author hasn't bothered to measure
>> the differences between various approaches, and pick a clear winner.
>>
> 
> I did pick NAPI in our previous submission based on various tests. But
> to get 10Gig line rate we need to use multiple Rx queues which will need
> fake netdevs.. Since fake netdevs weren't acceptable, I added non-NAPI
> support which gets 10Gig line rate with multi-rx. I am ok with removing
> NAPI support till the work of separating the netdevs and NAPI work is
> done..

That sounds fine to me.  Separating netdev and NAPI is the right way to 
go.  Maybe note that in a TODO list at the top of the driver.


> With SW LRO, non-NAPI is better but without LRO, NAPI is better but NAPI
> needs multiple Rx queues. So given the limitations, non-NPAI is my
> preference now.

On the subject of SW LRO:  We are really looking for a generic 
implementation, hopefully authored by one or more interested parties. 
This is something we definitely do not want to reinvent over and over in 
new drivers -- and in the one or two drivers it exists today, should be 
removed once the generic code is in place.

If Intel could assist with that effort, that would be very helpful.


> I will post the performance numbers later today..

Thanks,

	Jeff


