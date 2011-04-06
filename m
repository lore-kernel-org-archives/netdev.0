From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [Patch] iwlwifi: remove obsoleted module alias and parameters
Date: Wed, 6 Apr 2011 11:19:42 -0400
Message-ID: <20110406151942.GE11941@tuxdriver.com>
References: <1302083382-6715-1-git-send-email-amwang@redhat.com>
 <1302084582.3811.9.camel@jlt3.sipsolutions.net>
 <4D9C43A8.5060500@redhat.com>
 <20110406125728.GA2197@redhat.com>
 <20110406151429.GD11941@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <amwang@redhat.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Intel Linux Wireless <ilw@linux.intel.com>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Meenakshi Venkataraman <meenakshi.venkataraman@intel.com>,
	Larry Finger <Larry.Finger@lwfinger.net>
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51518 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756540Ab1DFPaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 11:30:25 -0400
Content-Disposition: inline
In-Reply-To: <20110406151429.GD11941@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 06, 2011 at 11:14:29AM -0400, John W. Linville wrote:
> On Wed, Apr 06, 2011 at 02:57:29PM +0200, Stanislaw Gruszka wrote:
> > On Wed, Apr 06, 2011 at 06:42:48PM +0800, Cong Wang wrote:
> > > =E4=BA=8E 2011=E5=B9=B404=E6=9C=8806=E6=97=A5 18:09, Johannes Ber=
g =E5=86=99=E9=81=93:
> > > >On Wed, 2011-04-06 at 17:49 +0800, Amerigo Wang wrote:
> > > >>As scheduled in Documentation/feature-removal-schedule.txt,
> > > >>remove "*50", "disable_hw_scan" module parameters and MODULE_AL=
IAS("iwl4965").
> > > >
> > > >Mostly fine, but for iwlegacy Stanislaw we want to keep hw scan =
(and it
> > > >was actually made default now)
> >=20
> > Indeed, disable_hw_scan should be removed in iwlwifi but leaved in =
iwlegacy.
> >=20
> > > Ok, I will wait for Stanislaw's response and then send an updated=
 patch.
> >=20
> > Have it now :-)
>=20
> Maybe the MODULE_ALIAS("iwl4965") should go to iwlegacy too?

Nevermind, forgot the "Internal alias support has been present in
module-init-tools" part...

--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
