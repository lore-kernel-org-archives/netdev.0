From: Jonas Bonn <jonas@southpole.se>
Subject: Re: struct pci_device_id declaration cleanups
Date: Thu, 06 Mar 2008 13:36:49 +0100
Message-ID: <47CFE561.2070104@southpole.se>
References: <1204800947-21569-1-git-send-email-jonas@southpole.se> <20080306122518.GB28561@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:51799 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933387AbYCFMgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 07:36:53 -0500
Received: from localhost (localhost [127.0.0.1])
	by mail.southpole.se (Postfix) with SMTP id ABBE14ED0F8
	for <netdev@vger.kernel.org>; Thu,  6 Mar 2008 13:36:52 +0100 (CET)
In-Reply-To: <20080306122518.GB28561@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Hellwig wrote:
> On Thu, Mar 06, 2008 at 11:55:38AM +0100, Jonas Bonn wrote:
>> This set of patches applies the macro DECLARE_PCI_DEVICE_TABLE to the 
>> declarations of struct pci_device_id in several network drivers.  The drivers
>> build cleanly with these patches (without any new warnings) on both x86 and 
>> PowerPC.
> 
> Why would we want this macro?  It looks slightly ugly at least..
> 
> 

Basically because the alternative would be along the lines of:

static const struct pci_device_id fst_pci_dev_id[] __devinitconst = {

...and this was deemed to be even uglier when I first brought this up a 
while back.

/Jonas

