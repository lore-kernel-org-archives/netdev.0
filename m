From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [1/5] 2.6.21-rc5: known regressions
Date: Wed, 28 Mar 2007 11:54:32 -0700
Message-ID: <460AB9E8.8070803@intel.com>
References: <Pine.LNX.4.64.0703251559560.6730@woody.linux-foundation.org> <20070327015929.GY16477@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	e1000-devel@lists.sourceforge.net, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>, Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:33016 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965658AbXC1Sye (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 14:54:34 -0400
In-Reply-To: <20070327015929.GY16477@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> Subject    : e1000 resume weirdness
> References : http://lkml.org/lkml/2007/3/26/91
> Submitter  : Ingo Molnar <mingo@elte.hu>
> Handled-By : Jesse Brandeburg <jesse.brandeburg@gmail.com>
>              Auke Kok <auke-jan.h.kok@intel.com>
> Status     : problem is being debugged

The issue comes from a corner case and the underlying problem is that e1000 
isn't stopping tx properly. We have a fix for this pending in our tree that I'll 
push upstream for 2.6.22 to Jeff, but I don't think this should be a blocker and 
it's probably is not a regression at all, the gap has always been present.

on a side note, this is probably fixed easily by turning the adapters 
detect_tx_hung flag off in e1000_down, so if someone spots this reoccurring 
somewhat regularly, please contact me so we can debug it. I myself have a system 
suspend/resuming in circles for an hour now with traffic flying across without a 
single hit on it....

Adrian, you probably want to drop this issue from your list.

Cheers,


Auke
