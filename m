From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC 43/72] a2065/ariadne: Move the a2065/ariadne drivers
Date: Mon, 11 Jul 2011 07:31:28 -0400
Message-ID: <20110711113128.GA21187@infradead.org>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1309010363-22750-44-git-send-email-jeffrey.t.kirsher@intel.com>
 <BANLkTin_SRhrd4dnfBH48b1aTikw5-mjtg@mail.gmail.com>
 <1310221836.26989.11.camel@jtkirshe-mobl>
 <CAMuHMdVHRNk4arc75QKrzDmHYE+86NixPk6v9uGwOAPkUTCgJw@mail.gmail.com>
 <1310345295.26989.76.camel@jtkirshe-mobl>
 <CAMuHMdXfpbbfv7oT+0oDWJd0=x0BBqEeCcGWaxMHagTXoeCscQ@mail.gmail.com>
 <1310377198.26989.90.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:50025
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752978Ab1GKLbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 07:31:32 -0400
Content-Disposition: inline
In-Reply-To: <1310377198.26989.90.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2011 at 02:39:57AM -0700, Jeff Kirsher wrote:
> It may just be me, these statements seem negative and bitter and is not
> helping us "solve" the issue.  While the statements may be true,  I
> would like to try and find a solution, what ever it may be, to better
> organize drivers/net/ethernet/ drivers to help with maintenance and
> future development.

It would help what the whole point of shuffling these drivers around
in arbitrary ways is.  Splitting them up for the actual protocols might
make some sense, as would giving a subdirectory to every non-trivial
driver.  But what whole vendor split, even if consistently implemented
seems like a lot of wanking for very little juice.

