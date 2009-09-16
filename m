From: Simon Horman <horms@verge.net.au>
Subject: Re: igb bandwidth allocation configuration
Date: Wed, 16 Sep 2009 17:04:43 +1000
Message-ID: <20090916070443.GB22495@verge.net.au>
References: <20090910081844.GA5421@verge.net.au>
 <15ddcffd0909140142n2a110708ld619177c65f4588b@mail.gmail.com>
 <20090915113659.GJ24194@verge.net.au>
 <4AAF963D.4060708@voltaire.com>
 <4AAFD690.5040900@intel.com>
 <20090915222926.GA24467@verge.net.au>
 <4AB08A00.40102@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	netdev <netdev@vger.kernel.org>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Or Gerlitz <ogerlitz@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:36535 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757149AbZIPHEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 03:04:40 -0400
Content-Disposition: inline
In-Reply-To: <4AB08A00.40102@voltaire.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 16, 2009 at 09:47:28AM +0300, Or Gerlitz wrote:
> Simon Horman wrote:
> >My reading of the documentation is also that its a minimum percentage of bandwidth. But after playing with the registers a bit it seems that it is actually a ceiling expressed. And the percentage is of 1Gigabit, regardless of the actual link speed.
> Hi,
> 
> Does the documentation you refer to is the 82576 one? if yes, can
> you send a pointer to the doc/section you refer to?

Yes, its the 82576. I'm looking at the 82576 datasheet.  In particular
section 4.5.11.1.5.1 "Configuring Tx Bandwidth to VMs", although there are
also some other sections covering the topic in that document.

> also is there
> 82599 (Niantic) documentation which is publicly avail and I can look
> at? specifically, I would love taking a look on the equivalent of
> the "Intel 82576 SR-IOV Driver Companion Guide"

Sorry, I don't know anything about the 82599. But I am only working

with publicly available documentation.
