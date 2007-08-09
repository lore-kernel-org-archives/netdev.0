From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [ewg] [PATCH 14/14] nes: kernel build infrastructure
Date: Thu, 09 Aug 2007 10:34:22 -0700
Message-ID: <ada643oobmp.fsf@cisco.com>
References: <200708080125.l781PVIM004915@neteffect.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ewg@lists.openfabrics.org
To: ggrundstrom@neteffect.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1-in.cisco.com ([171.71.176.70]:13720 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762862AbXHIRe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2007 13:34:29 -0400
In-Reply-To: <200708080125.l781PVIM004915@neteffect.com> (ggrundstrom@neteffect.com's message of "Tue, 7 Aug 2007 20:25:31 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > +ifdef CONFIG_INFINIBAND_NES_DEBUG
 > +EXTRA_CFLAGS += -DNES_DEBUG
 > +endif

I would just use the CONFIG_INFINIBAND_NES_DEBUG symbol directly in
your code.

 > +EXTRA_CFLAGS += -DNES_MINICM

If you're defining this unconditionally, can you just get rid of all
the tests of this symbol?

 - R.
