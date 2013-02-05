From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/15][pull request] Intel Wired LAN Driver Updates
 2013.02.05
Date: Tue, 05 Feb 2013 14:56:22 -0500 (EST)
Message-ID: <20130205.145622.1921760517987154305.davem@davemloft.net>
References: <1360058548-18158-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58503 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756586Ab3BET4Y convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 14:56:24 -0500
In-Reply-To: <1360058548-18158-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue,  5 Feb 2013 02:02:13 -0800

> This series contains updates to e1000e and ixgbe.  Majority of the pa=
tches
> are against e1000e, where Bruce makes several cosmetic #define moves =
into
> header files.  In addition, Bruce does a cleanup of braces to resolve
> checkpatch warnings (when using the strict option).
>=20
> Ixgbe patches contain several fixes as well as updating the copyright=
=2E  The
> fixes from Josh Hay, resolved a possible NULL pointer dereference and
> resolved Smatch warnings by fixing return values and memcpy parameter=
s.
> Alex provides 2 fixes, the first is to replace rmb() with
> read_barrier_depends() in the Tx cleanup.  The second fixes an MTU
> warning when using SR-IOV which corrects the fact that we were using =
1522
> to test for the max frame size in ixgbe_change_mtu and 1518 in
> ixgbe_set_vf_lpe.  The difference was the addition of VLAN_HLEN, whic=
h we
> only need to add in the case of computing a buffer size, but not a fi=
lter
> size.  Lastly, a patch from Emil which is based on a community patch =
from
> Aur=E9lien Guillaume which adds functions needed for reading SFF-8472
> diagnostic data from SFP modules.
>=20
> The following are changes since commit 27000929ef0f137b34ba219eb04b05=
e772eff2b1:
>   ipcomp: Mark as netns_ok.
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next mas=
ter

Pulled, thanks Jeff.
