From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: [PATCH] 2.6.27-rc9 QGLE make unsupported page size explicit compile failure
Date: Mon, 13 Oct 2008 20:19:02 -0600
Message-ID: <20081014021902.GY25780@parisc-linux.org>
References: <20081013060615.GB29358@colo.lackof.org> <20081012.230939.240550430.davem@davemloft.net> <20081014015455.GA25385@susedev.qlogic.org> <20081013.190345.20202604.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ron.mercer@qlogic.com, grundler@parisc-linux.org,
	linux-driver@qlogic.com, netdev@vger.kernel.org,
	linux-ia64@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palinux.external.hp.com ([192.25.206.14]:50507 "EHLO
	mail.parisc-linux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754938AbYJNCTF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 22:19:05 -0400
Content-Disposition: inline
In-Reply-To: <20081013.190345.20202604.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 13, 2008 at 07:03:45PM -0700, David Miller wrote:
> From: Ron Mercer <ron.mercer@qlogic.com>
> Date: Mon, 13 Oct 2008 18:54:55 -0700
> 
> > This ASIC does support all page sizes. For 4k and 8k page size the TX control block needs an external scatter gather list.  For page sizes larger than 8k the max frags is satisfied by the original TX control block.
> 
> I'm not applying this.  I _explicitly_ said I would not apply a
> solution like this.
> 
> I waited for you guys all day for this?!?!
> 
> We need to find a way to make this a Kconfig dependency.
> 
> Build failures are absolutely unacceptable.

Um, Dave, I think you misread his patch.

All it does it make the '64k case' the 'every other size case'.  There's
no build failure with Ron's patch.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
