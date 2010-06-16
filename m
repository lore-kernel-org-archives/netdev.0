From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] Clear IFF_XMIT_DST_RELEASE for teql interfaces
Date: Wed, 16 Jun 2010 09:25:45 -0400
Message-ID: <1276694745.3862.1.camel@bigi>
References: <1276676668-10256-1-git-send-email-tom@compton.nu>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>, Tejun Heo <tj@kernel.org>,
	linux-kernel@vger.kernel.org
To: Tom Hughes <tom@compton.nu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:36579 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066Ab0FPNZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 09:25:47 -0400
In-Reply-To: <1276676668-10256-1-git-send-email-tom@compton.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-06-16 at 09:24 +0100, Tom Hughes wrote:
> The sch_teql module, which can be used to load balance over a set of
> underlying interfaces, stopped working after 2.6.30 and has been
> broken in all kernels since then for any underlying interface which
> requires the addition of link level headers.
> 
> The problem is that the transmit routine relies on being able to
> access the destination address in the skb in order to do address
> resolution once it has decided which underlying interface it is going
> to transmit through.
> 
> In 2.6.31 the IFF_XMIT_DST_RELEASE flag was introduced, and set by
> default for all interfaces, which causes the destination address to be
> released before the transmit routine for the interface is called.
> 
> The solution is to clear that flag for teql interfaces.
> 
> Signed-off-by: Tom Hughes <tom@compton.nu>

Sounds reasonable. Lets CC Eric and get his ACK.

cheers,
jamal

