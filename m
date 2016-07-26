From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net-next 3/2] e1000e: convert systim overflow check to
 use flags2
Date: Tue, 26 Jul 2016 13:58:45 -0400
Message-ID: <20160726175845.GT36313@redhat.com>
References: <20160725105648.00000dda@unknown>
 <1469554746-410-1-git-send-email-jarod@redhat.com>
 <1469555635.2851.10.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f174.google.com ([209.85.216.174]:33650 "EHLO
	mail-qt0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756511AbcGZR65 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 13:58:57 -0400
Received: by mail-qt0-f174.google.com with SMTP id w38so14727439qtb.0
        for <netdev@vger.kernel.org>; Tue, 26 Jul 2016 10:58:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1469555635.2851.10.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 26, 2016 at 10:53:55AM -0700, Jeff Kirsher wrote:
> On Tue, 2016-07-26 at 13:39 -0400, Jarod Wilson wrote:
> > Per Jesse Brandeburg, e1000e should be using flags for this sort of
> > thing.
> >=20
> > Littering functional code with device-specific checks is much messi=
er
> > than
> > simply checking a flag, and having device-specific init set flags a=
s
> > needed.
> > There are probably a number of other cases in the e1000e code that
> > could/should be converted similarly.
> >=20
> > At present, this patch is a follow-up to the previously submitted 2
> > patches, but I can redo the series to omit the conversion to a swit=
ch
> > entirely, if so desired.
> >=20
> > Suggested-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> > CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
> > CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > CC: intel-wired-lan@lists.osuosl.org
> > CC: netdev@vger.kernel.org
> > Signed-off-by: Jarod Wilson <jarod@redhat.com>
> > ---
> > =A0drivers/net/ethernet/intel/e1000e/82571.c=A0=A0 |=A0 6 ++++--
> > =A0drivers/net/ethernet/intel/e1000e/e1000.h=A0=A0 |=A0 1 +
> > =A0drivers/net/ethernet/intel/e1000e/ich8lan.c |=A0 3 ++-
> > =A0drivers/net/ethernet/intel/e1000e/netdev.c=A0 | 10 ++--------
> > =A04 files changed, 9 insertions(+), 11 deletions(-)
>=20
> This generates a compile issue, so I will be dropping this patch and =
will
> await an update.

Yeah, just sent a note off-list, I really shouldn't send patches while =
on
conference calls. It's a typo in ich8lan.c, where I put FLAGS2_ instead=
 of
=46LAG2_. I'll just redo the entire set omitting the switch conversion.

--=20
Jarod Wilson
jarod@redhat.com
