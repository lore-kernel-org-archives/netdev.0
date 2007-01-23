From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 0/8] partial resend: e1000 fixes and updates
Date: Tue, 23 Jan 2007 16:31:41 -0500
Message-ID: <45B67EBD.6020605@pobox.com>
References: <20070113003650.16816.34076.stgit@gitlost.site> <45AFA6A4.4090503@pobox.com> <45AFAB7A.7040000@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50911 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965260AbXAWVbr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Jan 2007 16:31:47 -0500
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <45AFAB7A.7040000@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> Jeff Garzik wrote:
>> Kok, Auke wrote:
>>> Hi,
>>>
>>> This patch series contains exclusively fixes for e1000. Some of these 
>>> patches were
>>> already sent in december, but didn't make it into any usptream tree 
>>> yet. Most
>>> importantly, it addresses two issues in the recently merged msi 
>>> interrupt
>>> handler and dynamic itr code. A performance fix and some minor 
>>> cleanups are also
>>> added. This brings the driver up to version 7.3.20-k2.
>>>
>>> The summary below lists all patches. Once that were previously acked 
>>> are annotated
>>> with (*)
>>>
>>> These patches apply against netdev-2.6 #upstream-linus commit
>>> 77aab8bf22042d1658d4adbca8b71779e7f2d0ff. Please pull:
>>>
>>> git pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 
>>> upstream-linus
>>
>> Sigh.  I /know/ I've told you this before, but let's review the 
>> branches again.  NEVER EVER use branch 'upstream-linus'.  That is for 
>> Linus only.
> 
> gah, sorry about that.
> 
> I've moved it all over to #master-e1000 which applies against 
> bf81b46482c0fa8ea638e409d39768ea92a6b0f0 ("Linux 2.6.20-rc4 --Linus 
> Torvalds").
> 
> Please pull:
> 
> git pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 master-e1000

Strike my last email.

Pulled into #upstream.

	Jeff



