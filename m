From: "Brown, Aaron F" <aaron.f.brown@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH] igb: Fix VLAN tag stripping on Intel
	i350
Date: Thu, 11 Feb 2016 03:59:37 +0000
Message-ID: <309B89C4C689E141A5FF6A0C5FB2118B81E88113@ORSMSX101.amr.corp.intel.com>
References: <1453901284-32628-1-git-send-email-vinschen@redhat.com>
 <1453922722.3014.29.camel@intel.com>,<20160128125323.GA17357@calimero.vinschen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: Corinna Vinschen <vinschen@redhat.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:29248 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750765AbcBKD7j convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 22:59:39 -0500
In-Reply-To: <20160128125323.GA17357@calimero.vinschen.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Intel-wired-lan [intel-wired-lan-bounces@lists.osuosl.org] on behalf of Corinna Vinschen [vinschen@redhat.com]
> Sent: Thursday, January 28, 2016 4:53 AM
> To: Kirsher, Jeffrey T
> Cc: netdev@vger.kernel.org; intel-wired-lan@lists.osuosl.org
> Subject: Re: [Intel-wired-lan] [PATCH] igb: Fix VLAN tag stripping on Intel     i350
> 
> Hi Jeff,

On Jan 27 11:25, Jeff Kirsher wrote:
> On Wed, 2016-01-27 at 14:28 +0100, Corinna Vinschen wrote:
> > Problem: When switching off VLAN offloading on an i350, the VLAN
> > interface gets unusable.  For testing, set up a VLAN on an i350
> > and some remote machine, e.g.:
> > [...]
> I tried applying your patch to my tree for review and validation, but
> due to patches already applied against the igb driver in my tree, your
> patch does not apply cleanly.
>
> Can you please update your patch to apply cleanly to my tree?
> git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
> dev-queue
>
> (next-queue tree and dev-queue branch)
> 
> The attached patch is against the dev-queue branch of your next-queue tree.

Tested-by: Aaron Brown <aaron.f.brown@intel.com>
