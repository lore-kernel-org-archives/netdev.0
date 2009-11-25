From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [rfc 1/3 v2] [E1000-devel] [rfc 1/4] igb: Add igb_cleanup_vf()
Date: Tue, 24 Nov 2009 23:40:36 -0800
Message-ID: <9929d2390911242340t2e639719kc5ed80725f74a31d@mail.gmail.com>
References: <20091125063213.203372240@vergenet.net>
	 <20091125063530.796967189@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Arnd Bergmann <arndbergmann@googlemail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f180.google.com ([209.85.216.180]:60682 "EHLO
	mail-px0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752448AbZKYHk3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 02:40:29 -0500
Received: by pxi10 with SMTP id 10so5559433pxi.33
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2009 23:40:36 -0800 (PST)
In-Reply-To: <20091125063530.796967189@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 24, 2009 at 22:32, Simon Horman <horms@verge.net.au> wrote:
> Move virtual finction cleanup code into igb_cleanup_vf() and for the =
sake
> of symmetry rename igb_probe_vfs() as igb_init_vf().
>
> Although these functions aren't entirely symmetrical it should aid
> maintenance by making the relationship between initialisation and cle=
anup
> more obvious.
>
> Note that there appears to be no way for adapter->vfs_allocated_count=
 to be
> non-zero for the case where CONFIG_PCI_IOV is not set, so reseting th=
is
> value was moved to inside the relvant #ifdef.
>
> Signed-off-by: Simon Horman <horms@verge.net.au>
>
> ---
> Thu, 05 Nov 2009 11:58:48 +1100
> * Initial post
>
> Wed, 25 Nov 2009 15:43:45 +1100
> * Actually remove adapter->vfs_allocated_count =3D 0 from outside of
> =C2=A0igb_cleanup_vf()
> * Up-port to current net-next

Thanks Simon and congrats on the new addition!  I have added this
three patch series to my tree for review and testing.

--=20
Cheers,
Jeff
