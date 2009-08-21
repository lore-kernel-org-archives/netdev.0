From: Walt Holman <walt@holmansrus.com>
Subject: Re: Strange network timeouts w/ 2.6.30.5
Date: Fri, 21 Aug 2009 10:45:04 -0500 (CDT)
Message-ID: <987943678.21250869504786.JavaMail.root@mail.holmansrus.com>
References: <1489093361.01250869377567.JavaMail.root@mail.holmansrus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-76-164-182-57.apid.com ([76.164.182.57]:38666 "EHLO
	waltsputer.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754425AbZHUPyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2009 11:54:13 -0400
In-Reply-To: <1489093361.01250869377567.JavaMail.root@mail.holmansrus.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


----- "Krzysztof Halasa" <khc@pm.waw.pl> wrote:

> Walt Holman <walt@holmansrus.com> writes:
> 
> > Would something like passing a mem=xx cmdline on x86_64 be
> sufficient to test this?
> 
> I think so, though I admit I don't remember using this personally
> since
> the introduction of e820 RAM mapping support.
> Dmesg will show if the memory is limited. For the swiotlb to
> effectively
> disable no RAM > 0x100000000 may be used.
> 
> But this test isn't IMHO terribly important at this point - the
> driver
> makes invalid use of the DMA API and it has to change. The test could
> only explain _how_ exactly does it fail, we already know _why_ it
> does.
> -- 
> Krzysztof Halasa

Just got a chance to test this for confirmation.  When limiting the RAM to 2GB, the patched driver appears to work OK.

-Walt

