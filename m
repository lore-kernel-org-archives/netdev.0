From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: softmac mtu
Date: Thu, 28 Sep 2006 09:39:22 +0200
Message-ID: <1159429162.2648.0.camel@ux156>
References: <ef3s4u$or5$3@sea.gmane.org> <ef9a0b$4jb$4@sea.gmane.org>
	 <20060925200125.GF16949@tuxdriver.com>
	 <20060927143905.721ddf3e@griffin.suse.cz>
	 <1159365434.451a833ae7728@imp3-g19.free.fr>
	 <1159365316.2698.40.camel@ux156>  <451AB215.3080500@free.fr>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:7809 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751753AbWI1Hir
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 03:38:47 -0400
To: matthieu castet <castet.matthieu@free.fr>
In-Reply-To: <451AB215.3080500@free.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-09-27 at 19:17 +0200, matthieu castet wrote:

> > 2304, I think, as that's
> > synonym sMaxMsduLng Integer = 2304; /* max octets in an MSDU */
> > 
> 
> Yes but if it is bigger the frame get framented at the 802.11 layer : in 
> theory we could put mtu (IP max packet size) a big as we want [1].

No, you're confusing MPDU and MSDU. Or I am :) Please try to read the
spec as well.

johannes
