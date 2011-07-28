From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Add support for D-Link 530T rev C1 (Kernel Bug 38862)
Date: Thu, 28 Jul 2011 16:34:34 -0700
Message-ID: <20110728163434.4d3bb048@nehalam.ftrdhcpuser.net>
References: <20110728231811.GH8562@caffeine.csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	drivers_network@kernel-bugs.osdl.org
To: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59226 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755170Ab1G1XeY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jul 2011 19:34:24 -0400
In-Reply-To: <20110728231811.GH8562@caffeine.csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Jul 2011 19:18:11 -0400
lsorense@csclub.uwaterloo.ca (Lennart Sorensen) wrote:

> The D-Link DGE-530T rev C1 is a re-badged Realtek 8169 named DLG10028C,
> unlike the previous revisions which were skge based.  It is probably
> the same as the discontinued DGE-528T (0x4300) other than the PCI ID.
> 
> The PCI ID is 0x1186:0x4302.
> 
> Adding it to r8169.c where 0x1186:0x4300 is already found makes the card
> be detected and work.
> 
> This fixes https://bugzilla.kernel.org/show_bug.cgi?id=38862
> 
> Signed-off-by: Len Sorensen <lsorense@csclub.uwaterloo.ca>

Glad they at least changed the PCI-ID this time.
Other vendors have been known to do it wrong.
