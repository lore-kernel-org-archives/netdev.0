From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH] SELinux: Fix double free in selinux_netlbl_sock_setsid()
Date: Tue, 29 Jan 2008 12:13:53 -0500
Message-ID: <200801291213.54310.paul.moore@hp.com>
References: <20080129022026.7930.18782.stgit@flek.lan> <20080128.195124.188485009.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, bunk@kernel.org, jmorris@namei.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932931AbYA2ROc@vger.kernel.org>
In-Reply-To: <20080128.195124.188485009.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 28 January 2008 10:51:24 pm David Miller wrote:
> From: Paul Moore <paul.moore@hp.com>
> Date: Mon, 28 Jan 2008 21:20:26 -0500
>
> > As pointed out by Adrian Bunk, commit
> > 45c950e0f839fded922ebc0bfd59b1081cc71b70 caused a double-free when
> > security_netlbl_sid_to_secattr() fails.  This patch fixes this by
> > removing the netlbl_secattr_destroy() call from that function since we
> > are already releasing the secattr memory in
> > selinux_netlbl_sock_setsid().
> >
> > Signed-off-by: Paul Moore <paul.moore@hp.com>
>
> Applied, and I'll queue this up for -stable too.

Thanks.  Sorry for not catching this in the first place.

> Please, when mentioning specific commits please also provide
> the changelog headline along with the SHA1 hash.
>
> The reason is that when this fix is moved over to another
> tree where the SHA1 of the causing change is different people
> studying your fix won't be able to find it without more stable
> contextual information.

Noted, I'll make sure to include the patch description in the future.  I 
wasn't aware that the hash took into account anything other than the 
individual commit it represented.  However, now that I think about it, since 
order is so critical it only makes sense to have the hash take into account 
at least the previous commit.

-- 
paul moore
linux security @ hp
