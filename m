From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/2] r8169: allocate with GFP_KERNEL flag when able to
 sleep
Date: Mon, 11 Oct 2010 11:03:17 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1010111102390.11247@router.home>
References: <1286547901-10782-1-git-send-email-sgruszka@redhat.com>  <20101008145256.GB10393@redhat.com> <1286550247.2959.444.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stanislaw Gruszka <sgruszka@redhat.com>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp101.prem.mail.ac4.yahoo.com ([76.13.13.40]:36583 "HELO
	smtp101.prem.mail.ac4.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754977Ab0JKQDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 12:03:20 -0400
In-Reply-To: <1286550247.2959.444.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 8 Oct 2010, Eric Dumazet wrote:

> 8 in the <pagesperslab> column just says that : order-3 pages, even for
> small allocations.

Those allocations will fallback to smaller allocs if the page allocator
has trouble satisfying those requests.

