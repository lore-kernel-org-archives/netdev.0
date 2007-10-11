From: Dave Jones <davej@redhat.com>
Subject: Re: e100 problems in .23rc8 ?
Date: Thu, 11 Oct 2007 13:25:51 -0400
Message-ID: <20071011172551.GA21339@redhat.com>
References: <46FAA083.9020604@intel.com> <E1IanKN-0003ju-00@gondolin.me.apana.org.au> <20071011003638.GA27174@redhat.com> <20071011012520.GA13160@gondor.apana.org.au> <470E4AFA.60507@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert.xu@redhat.com>, netdev@vger.kernel.org,
	esandeen@redhat.com, dmack@juniper.net
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:38604 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754231AbXJKR0A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2007 13:26:00 -0400
Content-Disposition: inline
In-Reply-To: <470E4AFA.60507@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 11, 2007 at 09:10:34AM -0700, Kok, Auke wrote:
 > Herbert Xu wrote:
 > > On Wed, Oct 10, 2007 at 08:36:38PM -0400, Dave Jones wrote:
 > >> The e1000 changes you reference above, is this the changeset you mean?
 > >>
 > >> commit 416b5d10afdc797c21c457ade3714e8f2f75edd9
 > >> Author: Auke Kok <auke-jan.h.kok@intel.com>
 > >> Date:   Fri Jun 1 10:22:39 2007 -0700
 > >>
 > >>     e1000: disable polling before registering netdevice
 > > 
 > > Yep.
 > 
 > this patch actually called napi_disable() in the probe routine which was wrong,
 > but e100 does not do that. Nonetheless e100 doesn't call netif_carrier_off() and
 > netif_stop_queue(), so to make e100 the same as e1000 we should probably do this,
 > see below.
 > 
 > Dave, can you see if this resolves the issue for you? If so then we might want to
 > push this to -stable.
 
Will do, thanks Auke.

Eric/David, the Fedora 8 RPM version 2.6.23-6.fc8 will have this if you
want to give it a shot too.  It'll be at
http://people.redhat.com/davej/kernels/Fedora/f7.92/ when it's done
building in an hour or so.

	Dave

-- 
http://www.codemonkey.org.uk
