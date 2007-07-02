From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based
 PCI	Express adapters...
Date: Mon, 02 Jul 2007 10:41:00 -0400
Message-ID: <46890E7C.9070204@garzik.org>
References: <20070612234417.5102.29147.stgit@localhost.localdomain> <20070612234431.5102.33880.stgit@localhost.localdomain> <4688F512.3030801@garzik.org> <4689062A.8080809@linux.intel.com> <46890AED.7070906@garzik.org> <46890B39.4050909@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>,
	netdev@vger.kernel.org, auke-jan.h.kok@intel.com,
	akpm@linux-foundation.org
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52236 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755771AbXGBOlD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 10:41:03 -0400
In-Reply-To: <46890B39.4050909@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
> Jeff Garzik wrote:
>>>> always avoid bitfields.  They generate horrible code, and endian 
>>>> problems abound (though no endian problems are apparent here).
>>>
>>> they generate no worse code than open coding the checks for these 
>>> feature flags...
>>
>> That would be the logical assumption, but reality does not bear that 
>> logic out to be true.
>>
> 
> I just checked a small example and gcc just generates a testb with an 
> immediate value, which isn't all that bad code.
> 
> Do you remember which gcc you tested with?

gcc 2.95, gcc 3.x, gcc 4.x, ...  on multiple architectures, not just ia32.

It's simple logic:  using machine integers are the easiest for the 
compiler to Do The Right Thing, the easiest way to eliminate endian 
problems, the easiest way for programmers to read and understand struct 
alignment.

Just say no to bitfields.

	Jeff



