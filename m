From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: igb bandwidth allocation configuration
Date: Mon, 14 Sep 2009 11:42:50 +0300
Message-ID: <15ddcffd0909140142n2a110708ld619177c65f4588b@mail.gmail.com>
References: <20090910081844.GA5421@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Alexander Duyck <alexander.duyck@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Or Gerlitz <ogerlitz@voltaire.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:53316 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915AbZINImr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 04:42:47 -0400
Received: by fxm17 with SMTP id 17so673528fxm.37
        for <netdev@vger.kernel.org>; Mon, 14 Sep 2009 01:42:50 -0700 (PDT)
In-Reply-To: <20090910081844.GA5421@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/10/09, Simon Horman <horms@verge.net.au> wrote:
> I have been looking into adding support the 82586's per-PF/VF bandwidth allocation to
> the igb driver. It seems that the trickiest part is working out how to expose things to
> user-space.

Please note that there are bunch (not many, but more then 1-2) of
things to configure from user space in a PF/VF scheme, and I think it
would be best if we do that through one mechanism, which may be
netlink based or extension to ethtool as you suggested, we've started
to discuss this on the "L2 switching in igb" thread

The "82576 SR-IOV Driver Companion Guide" document, section 7.6
mentions "Transmit Bandwidth Allocation to VFs... define minimum
transmit bandwidth for individual VMs".

I'm not clear if one can program rate limiter (upper bound) per VF or
actually rate guarantee per VF, even  with these being  just details
of specific device, alex, I would be happy if you can clarify that.


Or.
