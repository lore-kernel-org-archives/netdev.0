From: David Miller <davem@davemloft.net>
Subject: Re: [SPARC64] INO problem Re: [Bug 10273] New: Sun GEM (PCI) -
 network device doesn't work
Date: Fri, 25 Apr 2008 13:35:58 -0700 (PDT)
Message-ID: <20080425.133558.15713665.davem@davemloft.net>
References: <20080402182655.GA2739@ami.dom.local>
	<20080425.002636.250010462.davem@davemloft.net>
	<20080425215905.0d21f5ca.seraph@xs4all.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	linux-kernel@vger.kernel.org
To: seraph@xs4all.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38590
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755751AbYDYUf6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 16:35:58 -0400
In-Reply-To: <20080425215905.0d21f5ca.seraph@xs4all.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jos van der Ende <seraph@xs4all.nl>
Date: Fri, 25 Apr 2008 21:59:05 +0200

> > Please give this patch a try (this is against 2.6.23, which is the
> > version you reported the bug against, let me know if another version
> > is more convenient).
> 
> I applied the patch against 2.6.24-gentoo-r4, the current kernel on this machine. It worked fine, with only an offset of 12 lines. Nothing unusual during compile either.
> 
> The first results are hopeful: I am no longer able to trigger this bug by loading sym53c8xx before sungem, nor by having them both loaded by udev. Nothing odd in dmesg and the machine is completely functional.
> 
> 
> I don't have much time for testing today, but if desired I will gladly do some more testing tomorrow or Sunday.

Thanks for testing the change, I'll do some of my own testing and push
the bug fix upstream.

Thanks again!
