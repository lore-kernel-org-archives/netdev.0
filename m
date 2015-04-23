From: Sathya Perla <Sathya.Perla@Emulex.Com>
Subject: RE: [PATCH net-next v2] be2net: log link status
Date: Thu, 23 Apr 2015 06:35:16 +0000
Message-ID: <cd4ee8b8-0303-48f9-ac7f-95b998592462@CMEXHTCAS1.ad.emulex.com>
References: <1429710210-7291-1-git-send-email-ivecera@redhat.com>
 <1429711674.32612.8.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Subramanian Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Kumar Khaparde <Ajit.Khaparde@Emulex.Com>
To: Joe Perches <joe@perches.com>, Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:3529 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751356AbbDWGfY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 02:35:24 -0400
In-Reply-To: <1429711674.32612.8.camel@perches.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Joe Perches [mailto:joe@perches.com]
> 
> On Wed, 2015-04-22 at 15:43 +0200, Ivan Vecera wrote:
> > The driver unlike other drivers does not log link state changes.
> 
...
> 
> Question for the emulex folk:
> 
> Is the dom argument to link_status_query necessary?
> It's currently always 0.

It's needed only if the PF wants to query the "link_status" of a VF, which
it doesn't do currently...
Yes, its un-necessary and can be removed (in a separate patch I guess :-)).

thanks,
-Sathya
