From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/5] qed/qede: Tunnel hardware GRO support
Date: Wed, 22 Jun 2016 16:31:32 -0700
Message-ID: <1466638292.6850.94.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1466583926-27762-1-git-send-email-manish.chopra@qlogic.com>
	 <CAKgT0Ue6_cPb88wfTtMMetJzBSJnGDNWj8YVHWC=9WdztCxOuQ@mail.gmail.com>
	 <CO2PR11MB008891D4ECFF86F32B1C32CC972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
	 <CAKgT0UdDt6H8ix6U7n_uPjodkXYuxviZjSKWQRaXu2_qWWEL+A@mail.gmail.com>
	 <CO2PR11MB0088C4DEAFEE71B0D865DB33972C0@CO2PR11MB0088.namprd11.prod.outlook.com>
	 <576B08A2.8080603@hpe.com>
	 <1466635664.6850.90.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAKgT0UdbPVqpSVLs0JW7zFU7mNtJn5BM+fMjsr1tLm4kHRcW9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hpe.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@redhat.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36796 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbcFVXbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 19:31:34 -0400
Received: by mail-pa0-f50.google.com with SMTP id wo6so21093019pac.3
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 16:31:34 -0700 (PDT)
In-Reply-To: <CAKgT0UdbPVqpSVLs0JW7zFU7mNtJn5BM+fMjsr1tLm4kHRcW9A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-06-22 at 15:56 -0700, Alexander Duyck wrote:

> It could be that you and Rick are running different firmware. I
> believe you can expose that via "ethtool -i".  This is the ugly bit
> about all this.  We are offloading GRO into the firmware of these
> devices with no idea how any of it works and by linking GRO to LRO on
> the same device you are stuck having to accept either the firmware
> offload or nothing at all.  That is kind of the point Rick was trying
> to get at.


Well, we offload TSO to the NIC. Or checksums as much as we can.

At one point we have to trust the NIC we plug in our hosts, right ?

Why RX is so different than TX exactly ?

Yes, LRO is hard to implement properly compared to TSO,
but not something that is _fundamentally_ broken.

Claiming that hardware assist GRO is not possible is a plain mantra.
