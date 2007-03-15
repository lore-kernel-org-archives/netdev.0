From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch 1/4] network dev read_mostly
Date: 15 Mar 2007 16:10:52 +0100
Message-ID: <p731wjq8rur.fsf@bingen.suse.de>
References: <20070312210817.485320783@linux-foundation.org>
	<20070312210907.509184287@linux-foundation.org>
	<20070315021840.GG1246@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33938 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965172AbXCOOLt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2007 10:11:49 -0400
In-Reply-To: <20070315021840.GG1246@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Benjamin LaHaise <bcrl@kvack.org> writes:

> On Mon, Mar 12, 2007 at 02:08:18PM -0700, Stephen Hemminger wrote:
> > For Eric, mark packet type and network device watermarks
> > as read mostly.
> 
> The following x86-64 bits might be intersting, as they allow you to 
> completely eliminate the memory access for run time defined constants.  

I like the concept, although the patch could still need a few cleanups.
But it would be useful in a couple of cases.

Disadvantage: it will likely lead to even more weird sysctls and hooks
because one of the best argument against them will be gone then @)

-Andi

