From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] [RFC] vlan: fix updating wanted_features for vlan
 device
Date: Thu, 5 May 2011 08:51:53 +0200
Message-ID: <20110505065153.GA3288@rere.qmqm.pl>
References: <20110505004841.26691.74872.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	devel@open-fcoe.org
To: Yi Zou <yi.zou@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:47102 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751002Ab1EEGvz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2011 02:51:55 -0400
Content-Disposition: inline
In-Reply-To: <20110505004841.26691.74872.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 04, 2011 at 05:48:42PM -0700, Yi Zou wrote:
> commit 8a0427b "vlan: convert VLAN devices to use ndo_fix_features()"=
 converts the
> vlan to support ndo_fix_features. However, the wanted_features is not=
 updated
> for the vlan device, causing real_dev->features not be populated to t=
he vlan
> device when real_dev->features are changed by the driver through FEAT=
_CHANGE.
> This is breaking FCoE related netdev feature flags on vlan devices. A=
dd updating
> wanted_features to vlan_transfer_features() so netdev_get_wanted_feat=
ures() will
> can get the updated wanted feature flags for vlan device properly.

Can you describe the situation further? There might be problems if devi=
ce
changes its vlan_features after creation of VLAN devices on top (bondin=
g?).

dev->wanted_features is only what user wants to get and should not be c=
hanged
by anything else.

Best Regards,
Micha=B3 Miros=B3aw
