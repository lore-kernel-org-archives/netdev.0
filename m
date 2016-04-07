From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [PATCH net-next] net: intel: remove dead links
Date: Thu, 7 Apr 2016 02:31:26 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81ECB9E0@ORSMSX101.amr.corp.intel.com>
References: <3c9f8ea384ba033f83ec360eef17732ff0a5a8dd.1459866280.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: Jiri Benc <jbenc@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:62485 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752267AbcDGCbf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 22:31:35 -0400
In-Reply-To: <3c9f8ea384ba033f83ec360eef17732ff0a5a8dd.1459866280.git.jbenc@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Jiri Benc
> Sent: Tuesday, April 5, 2016 7:25 AM
> To: netdev@vger.kernel.org
> Cc: Kirsher, Jeffrey T <jeffrey.t.kirsher@intel.com>; Brandeburg, Jesse
> <jesse.brandeburg@intel.com>; Nelson, Shannon
> <shannon.nelson@intel.com>; Wyborny, Carolyn
> <carolyn.wyborny@intel.com>; Skidmore, Donald C
> <donald.c.skidmore@intel.com>; Allan, Bruce W <bruce.w.allan@intel.com>;
> Ronciak, John <john.ronciak@intel.com>; Williams, Mitch A
> <mitch.a.williams@intel.com>; intel-wired-lan@lists.osuosl.org
> Subject: [PATCH net-next] net: intel: remove dead links
> 
> The Kconfig for Intel NICs references two different URLs for the "Adapter
> & Driver ID Guide". Neither of those two links works. The current URL seems
> to be
> http://www.intel.com/content/www/us/en/support/network-and-i-
> o/ethernet-products/000005584.html
> but given it's apparently constantly changing, there's no point in having it
> in the help text.
> 
> Just keep a generic pointer to http://support.intel.com. Hopefully, this one
> will have a longer live. It still works, at least.
> 
> Futhermore, remove a link to "the latest Intel PRO/100 network driver for
> Linux", this has no place in the mainline kernel and the latest Linux driver
> it offers is from 2006, anyway.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
>  drivers/net/ethernet/intel/Kconfig | 80 +++++++-------------------------------
>  1 file changed, 14 insertions(+), 66 deletions(-)

If reading through the file qualifies as tested...

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
