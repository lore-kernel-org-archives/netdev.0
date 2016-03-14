From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH v2 net-next] ixgbe: Avoid unaligned access in ixgbe_atr()
 for LLC packets
Date: Mon, 14 Mar 2016 15:32:59 -0400
Message-ID: <20160314193259.GL5084@oracle.com>
References: <20160314174624.GG5084@oracle.com>
 <CAKgT0Ucnf7Yyzjp_vccimVmjx-ZbYnOfKoTt6rEEZOsOEhVboQ@mail.gmail.com>
 <20160314175909.GH5084@oracle.com>
 <CAKgT0Ud9b7MaOk-O4gs3LCMgO+dApCFJ=tOrStk1kuxEE5dShw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Netdev <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	shannon nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	Bruce W Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:24713 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932148AbcCNTdO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 15:33:14 -0400
Content-Disposition: inline
In-Reply-To: <CAKgT0Ud9b7MaOk-O4gs3LCMgO+dApCFJ=tOrStk1kuxEE5dShw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (03/14/16 12:20), Alexander Duyck wrote:
> I figure it is better to just drop it since we don't need to be trying
> to parse ARP packets anyway.

Ok, let me send out v3.
