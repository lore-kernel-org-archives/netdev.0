From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Linux 2.6.35/TIPC 2.0 ABI breaking changes
Date: Tue, 19 Oct 2010 00:58:19 +0100
Message-ID: <20101019005819.24c8d373@lxorguk.ukuu.org.uk>
References: <20101018150422.GV8781@llucax.com.ar>
	<20101018184628.GX8781@llucax.com.ar>
	<AANLkTimKbOreV4Fuyw3TbCrk9aa5yBZQSuRbo3Vdx=Q1@mail.gmail.com>
	<20101018.151708.193712688.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, luca@llucax.com.ar,
	jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:33207 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932867Ab0JRX7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 19:59:36 -0400
In-Reply-To: <20101018.151708.193712688.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 Oct 2010 15:17:08 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Paul Gortmaker <paul.gortmaker@windriver.com>
> Date: Mon, 18 Oct 2010 16:42:33 -0400
> 
> > If you have access to the user space code in question, you can just
> > switch behaviour semantics based on the results of a uname call, knowing
> > that this change was included in versions since approx last Feb.  There
> > is also /proc/version which can be parsed manually if you prefer.
> 
> Requiring userspace to check kernel versioning information in order
> to user an exported userspace API correctly is _ALWAYS_ _WRONG_.
> 
> You cannot and must not make backwards incompatible changes to
> userspace interfaces.
> 
> Really, you can't.

In which case given that most distros are shipping older stuff and care
about ABI stability presumably the bug should get fixed for 2.6.36 ?
