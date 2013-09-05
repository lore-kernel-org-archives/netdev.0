From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [E1000-devel] [net-next v4 7/8] i40e: sysfs and debugfs interfaces
Date: Thu, 05 Sep 2013 13:10:19 +0200
Message-ID: <8761uf5xt0.fsf@nemi.mork.no>
References: <1378336629-24224-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1378336629-24224-8-git-send-email-jeffrey.t.kirsher@intel.com>
	<20130904173759.7c2eec52@nehalam.linuxnetplumber.net>
	<FC41C24E35F18A40888AACA1A36F3E416C61CF23@FMSMSX102.amr.corp.intel.com>
	<CAOaVG17stH4K=MOfB0-OfqerVOmXpGQtERD7kgCF97AOtpn18A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Nelson\, Shannon" <shannon.nelson@intel.com>,
	"Kirsher\, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"e1000-devel\@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"Brandeburg\, Jesse" <jesse.brandeburg@intel.com>,
	"gospo\@redhat.com" <gospo@redhat.com>,
	"davem\@davemloft.net" <davem@davemloft.net>,
	"sassmann\@redhat.com" <sassmann@redhat.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:56276 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759608Ab3IELLH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 07:11:07 -0400
In-Reply-To: <CAOaVG17stH4K=MOfB0-OfqerVOmXpGQtERD7kgCF97AOtpn18A@mail.gmail.com>
	(Stephen Hemminger's message of "Wed, 4 Sep 2013 21:55:39 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <stephen@networkplumber.org> writes:

> More surprising is that others did not see the same things.

If I were to guess the 3 primary reasons for that:
  1) the series is too large for anyone to actually read it all without
     being paid to do so
  2) the sysfs code is at the end of a huge debugfs patch, which
     probably noone cares about whether they are paid or not
  3) the small sysfs patch is so full of minor issues to nit about that
     it seems pointless to even start

But since I looked at it, I can name a few other obvious issues with th=
e
sysfs patch:
 - mix of macro and octal mode values
 - no documentation (required for all new sysfs attributes according to
    Documentation/filesystems/sysfs.txt)
 - extremely dubious kboject usage and attribute creation/deletion (How
    does this fit into the driver model?  How will userspace race with
    these attributes being added and removed?)

I am sure there are plenty more.


Bj=C3=B8rn
