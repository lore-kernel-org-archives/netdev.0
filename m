From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [TULIP] Fix section mismatch in de2104x.c
Date: Fri, 06 Oct 2006 14:50:59 -0400
Message-ID: <4526A593.6080804@garzik.org>
References: <11601583542790-git-send-email-matthew@wil.cx> <4526A2ED.6030406@garzik.org> <20061006184517.GL2563@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Val Henson <val_henson@linux.intel.com>, netdev@vger.kernel.org,
	Helge Deller <deller@parisc-linux.org>,
	Kyle McMartin <kyle@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47782 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1422837AbWJFSvD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2006 14:51:03 -0400
To: Matthew Wilcox <matthew@wil.cx>
In-Reply-To: <20061006184517.GL2563@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matthew Wilcox wrote:
> On Fri, Oct 06, 2006 at 02:39:41PM -0400, Jeff Garzik wrote:
>> I'm a bit blind, so help me out here...  what precisely is mismatched?
>>
>> AFAICS everything is properly marked __init or __exit.
> 
> Wasn't my patch, but the markings are now consistent with tulip_core at least.

That's a totally separate driver :)

These section mismatch warnings occasionally stump me, and this is one 
of them.  I don't want to ACK it until I know _why_ it is needed...

	Jeff



