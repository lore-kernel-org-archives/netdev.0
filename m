From: Valerie Henson <val_henson@linux.intel.com>
Subject: More info on section mismatches (was Re: [PATCH] [TULIP] Fix section mismatch in de2104x.c)
Date: Fri, 6 Oct 2006 12:25:21 -0700
Message-ID: <20061006192520.GB8620@goober>
References: <11601583542790-git-send-email-matthew@wil.cx> <4526A2ED.6030406@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Wilcox <matthew@wil.cx>, netdev@vger.kernel.org,
	Helge Deller <deller@parisc-linux.org>,
	Kyle McMartin <kyle@parisc-linux.org>,
	Richard Henderson <rth@twiddle.net>,
	Arjan van de Ven <arjan@linux.intel.com>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:17039 "EHLO mga09.intel.com")
	by vger.kernel.org with ESMTP id S932461AbWJFTZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2006 15:25:55 -0400
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <4526A2ED.6030406@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 06, 2006 at 02:39:41PM -0400, Jeff Garzik wrote:
> Matthew Wilcox wrote:
> >From: Helge Deller <deller@parisc-linux.org>
> >
> >WARNING: drivers/net/tulip/de2104x.o - Section mismatch: reference to 
> >.init.text:de_init_one from .data.rel.local after 'de_driver' (at offset 
> >0x20)
> >WARNING: drivers/net/tulip/de2104x.o - Section mismatch: reference to 
> >.exit.text:de_remove_one from .data.rel.local after 'de_driver' (at offset 
> >0x28)
> 
> I'm a bit blind, so help me out here...  what precisely is mismatched?
> 
> AFAICS everything is properly marked __init or __exit.

(Cc'd Richard Henderson as resident gcc guru.)

We're discussing a way to get more information out of section mismatch
reports so that the causes of section mismatches are a little more
obvious.  I'd like to see something like:

foo() is marked __init at line 34
bar() calls foo() at line 57

Arjan points out that optimization may make this difficult; I'm happy
with a separate script running at a lower level of optimization that
you can run by hand when one of these warnings shows up.

Ideas?

-VAL
