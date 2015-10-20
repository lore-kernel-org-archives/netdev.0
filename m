From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [PATCH] intel: i40e: fix confused code
Date: Tue, 20 Oct 2015 15:39:21 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418AFA524B@fmsmsx115.amr.corp.intel.com>
References: <1445115499-28728-1-git-send-email-linux@rasmusvillemoes.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57042 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750785AbbJTPjo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2015 11:39:44 -0400
In-Reply-To: <1445115499-28728-1-git-send-email-linux@rasmusvillemoes.dk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Rasmus Villemoes [mailto:linux@rasmusvillemoes.dk]
> Sent: Saturday, October 17, 2015 1:58 PM
> Subject: [PATCH] intel: i40e: fix confused code
> 
> This code is pretty confused. The variable name 'bytes_not_copied'
> clearly indicates that the programmer knew the semantics of
> copy_{to,from}_user, but then the return value is checked for being
> negative and used as a -Exxx return value.
> 
> I'm not sure this is the proper fix, but at least we get rid of the
> dead code which pretended to check for access faults.
> 
> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> ---

Acked-by: Shannon Nelson <shannon.nelson@intel.com>
