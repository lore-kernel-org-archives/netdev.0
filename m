From: Andi Kleen <ak@muc.de>
Subject: Re: [PATCH 1/5] r8169: auto detect 32-bit slot
Date: Wed, 09 Mar 2005 21:16:05 +0100
Message-ID: <m17jkgwp6i.fsf@muc.de>
References: <20050309112925.7f7900ab@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050309112925.7f7900ab@dxpl.pdx.osdl.net> (Stephen
 Hemminger's message of "Wed, 9 Mar 2005 11:29:25 -0800")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> writes:

> Change driver to auto-detect when the board is in a 32-bit PCI slot and
> avoid setting 64-bit dma mask. The module parameter method is no longer needed.

Hmm? It doesn't support DAC? 

Normally on PCI a 64bit slot is not needed for 64bit addresses.

-Andi
