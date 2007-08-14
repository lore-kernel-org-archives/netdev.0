From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [patch 12/18] e1000: #if 0 two functions
Date: Tue, 14 Aug 2007 14:14:40 -0700
Message-ID: <46C21B40.1050301@intel.com>
References: <200708102105.l7AL5M0O008980@imap1.linux-foundation.org> <46C13F54.3030508@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org, bunk@stusta.de
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:9834 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756332AbXHNVPK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Aug 2007 17:15:10 -0400
In-Reply-To: <46C13F54.3030508@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> akpm@linux-foundation.org wrote:
>> From: Adrian Bunk <bunk@stusta.de>
>>
>> e1000_{read,write}_pci_cfg() are no longer used.
>>
>> Signed-off-by: Adrian Bunk <bunk@stusta.de>
>> Cc: Auke Kok <auke-jan.h.kok@intel.com>
>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>> ---
>>
>>  drivers/net/e1000/e1000_hw.h   |    2 --
>>  drivers/net/e1000/e1000_main.c |    4 ++++
>>  2 files changed, 4 insertions(+), 2 deletions(-)
> 
> if it's truly dead code in upstream, we should just remove it from e1000

if I apply this to #master and compile, it blows up: the two functions are still 
in use there. I also don't see any difference with current #upstream....

so, I don't know what is in -mm at the moment, but we do not want this in jeff's 
tree.

Auke
