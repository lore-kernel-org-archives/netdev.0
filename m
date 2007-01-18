From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 0/8] partial resend: e1000 fixes and updates
Date: Thu, 18 Jan 2007 09:16:42 -0800
Message-ID: <45AFAB7A.7040000@intel.com>
References: <20070113003650.16816.34076.stgit@gitlost.site> <45AFA6A4.4090503@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15356 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752070AbXARRQr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jan 2007 12:16:47 -0500
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <45AFA6A4.4090503@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Kok, Auke wrote:
>> Hi,
>>
>> This patch series contains exclusively fixes for e1000. Some of these 
>> patches were
>> already sent in december, but didn't make it into any usptream tree 
>> yet. Most
>> importantly, it addresses two issues in the recently merged msi interrupt
>> handler and dynamic itr code. A performance fix and some minor 
>> cleanups are also
>> added. This brings the driver up to version 7.3.20-k2.
>>
>> The summary below lists all patches. Once that were previously acked 
>> are annotated
>> with (*)
>>
>> These patches apply against netdev-2.6 #upstream-linus commit
>> 77aab8bf22042d1658d4adbca8b71779e7f2d0ff. Please pull:
>>
>> git pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream-linus
> 
> Sigh.  I /know/ I've told you this before, but let's review the branches 
> again.  NEVER EVER use branch 'upstream-linus'.  That is for Linus only.

gah, sorry about that.

I've moved it all over to #master-e1000 which applies against 
bf81b46482c0fa8ea638e409d39768ea92a6b0f0 ("Linux 2.6.20-rc4 --Linus Torvalds").

Please pull:

git pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 master-e1000


Thanks,

Auke


> * If there are no dependent e1000 changes, send patches against master 
> (or torvalds/linux-2.6.git, if you prefer)
> * If there are dependent e1000 changes in #upstream-fixes, send patches 
> against #upstream-fixes
> * If there are dependent e1000 changes in #upstream, send patches 
> against #upstream

*writes cheatsheet*
