From: Dave Jones <davej@redhat.com>
Subject: Re: net: cdc_ncm, cdc_mbim: allow user to prefer NCM for backwards
 compatibility
Date: Thu, 16 May 2013 15:17:01 -0400
Message-ID: <20130516191701.GC5805@redhat.com>
References: <20130516182510.GA4728@redhat.com>
 <87mwrueo9k.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	Fedora Kernel Team <kernel-team@fedoraproject.org>,
	Ben Hutchings <ben@decadent.org.uk>
To: =?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19985 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752495Ab3EPTRR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 May 2013 15:17:17 -0400
Content-Disposition: inline
In-Reply-To: <87mwrueo9k.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 16, 2013 at 09:08:23PM +0200, Bj=F8rn Mork wrote:
 > Yes, this is a very unfortunate side effect of the userspace/kernel
 > split of the MBIM driver combined with the NCM/MBIM "backwards
 > compatibility" setting.  Which in itself is a bad idea, IMHO.
 >=20
 > I recommend all distros do the same as Debian: Set NCM as default un=
til
 > a userspace application with MBIM support is ready and packaged in t=
he
 > distro:
 > http://anonscm.debian.org/viewvc/kernel/dists/trunk/linux/debian/pat=
ches/debian/cdc_ncm-cdc_mbim-use-ncm-by-default.patch

Thanks for the pointer. We'll pick that up for the Fedora 3.9 kernels.

Ben, does debian have a commits mailing list for kernel changes ?

 > FWIW, I wish we would have thought about this issue before v3.8 was
 > released.  Then we could have made that patch the mainline default,
 > without that being a userspace API change.  But we didn't.
 >=20
 > The good news is that Aleksander has done some nice work on the MBIM
 > support in ModemManager, so there is a good chance that the next rel=
ease
 > will make this problem go away.

good news indeed!

thanks.

	Dave
