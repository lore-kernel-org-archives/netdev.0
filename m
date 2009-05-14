From: Or Gerlitz <ogerlitz@Voltaire.com>
Subject: Re: user space virtio-net exits with "truncating packet" error
Date: Thu, 14 May 2009 15:25:35 +0300
Message-ID: <4A0C0DBF.3010201@Voltaire.com>
References: <Pine.LNX.4.64.0905141258570.31748@zuben.voltaire.com> <1242300155.17366.20.camel@blaa>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>, Avi Kivity <avi@redhat.com>,
	netdev@vger.kernel.org, Gregory Haskins <ghaskins@novell.com>,
	qemu-devel <qemu-devel@nongnu.org>,
	Anthony Liguori <anthony@codemonkey.ws>
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:40518 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756637AbZENMZm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 May 2009 08:25:42 -0400
In-Reply-To: <1242300155.17366.20.camel@blaa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mark McLoughlin wrote:
> That sounds like a bug in qemu's mergeable receive buffers
> implementation - the host is running out of buffers for the packet, even
> though it supposedly has already checked that there is enough buffers
> available on the ring.
> 
> Hmm, I think I see the bug - does the patch below work? Please try
> several mtu values around the 9k mark to be sure

No, it doesn't help, same crash.

Or.
