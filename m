From: Or Gerlitz <ogerlitz@Voltaire.com>
Subject: Re: 2.6.31 ARP related problems
Date: Wed, 02 Sep 2009 15:20:11 +0300
Message-ID: <4A9E62FB.6090000@Voltaire.com>
References: <Pine.LNX.4.64.0909011347350.19568@zuben.voltaire.com> <m163c2ztrf.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:30949 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751050AbZIBMUX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 08:20:23 -0400
In-Reply-To: <m163c2ztrf.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric W. Biederman wrote:
> I just tested.  If the two macvlans are in separate network namespaces all is well,
> so definitely not macvlan. As you have observed there are no real changes to arp.c

Yes, it's not macvlan to blame, I just tested it in SR-IOV scheme with igb/igbvf and
I see the same problem, only ping that goes through / targeted to the IP address of the first
VF device routing hit works, which means SR-IOV isn't really usable with 2.6.31 when you want 
a multiple VMs scheme, each attached to a different VF and all VMs on the same network segment.


Or.
