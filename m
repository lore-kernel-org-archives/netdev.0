From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] SELinux: Fix double free in
 selinux_netlbl_sock_setsid()
Date: Mon, 28 Jan 2008 19:51:24 -0800 (PST)
Message-ID: <20080128.195124.188485009.davem@davemloft.net>
References: <20080129022026.7930.18782.stgit@flek.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, stable@kernel.org, bunk@kernel.org,
	jmorris@namei.org
To: paul.moore@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38747
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753043AbYA2DvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 22:51:07 -0500
In-Reply-To: <20080129022026.7930.18782.stgit@flek.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul.moore@hp.com>
Date: Mon, 28 Jan 2008 21:20:26 -0500

> As pointed out by Adrian Bunk, commit 45c950e0f839fded922ebc0bfd59b1081cc71b70
> caused a double-free when security_netlbl_sid_to_secattr() fails.  This patch
> fixes this by removing the netlbl_secattr_destroy() call from that function
> since we are already releasing the secattr memory in
> selinux_netlbl_sock_setsid().
> 
> Signed-off-by: Paul Moore <paul.moore@hp.com>

Applied, and I'll queue this up for -stable too.

Please, when mentioning specific commits please also provide
the changelog headline along with the SHA1 hash.

The reason is that when this fix is moved over to another
tree where the SHA1 of the causing change is different people
studying your fix won't be able to find it without more stable
contextual information.

Thanks.
