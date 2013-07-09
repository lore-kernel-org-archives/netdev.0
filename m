From: hayeswang <hayeswang@realtek.com>
Subject: RE: Extremely bad performance with RTL8111/8168B
Date: Tue, 9 Jul 2013 10:24:20 +0800
Message-ID: <88C0E945471D46EEA556B43C7EB384AB@realtek.com.tw>
References: <20130708095459.GA29788@amd.pavel.ucw.cz> <1373291269.4979.102.camel@edumazet-glaptop> <20130708220149.GA15766@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: 'Pavel Machek' <pavel@ucw.cz>, <netdev@vger.kernel.org>,
	'nic_swsd' <nic_swsd@realtek.com>
To: 'Francois Romieu' <romieu@fr.zoreil.com>,
	'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:53188 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056Ab3GICYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jul 2013 22:24:35 -0400
In-Reply-To: <20130708220149.GA15766@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Tuesday, July 09, 2013 6:02 AM
> To: Eric Dumazet
> Cc: Pavel Machek; Hayeswang; netdev@vger.kernel.org
> Subject: Re: Extremely bad performance with RTL8111/8168B
> 
> Eric Dumazet <eric.dumazet@gmail.com> :
> [8168d failure]
> > It looks like TSO packets are not transmitted, so TCP only 'works'
> > because retransmits use non TSO packets.
> > 
> > Could you report "ethtool -k eth0" ?
> > 
> > try : ethtool -K eth0 tso off
> 
> If so it could be worth adding a test for RTL_GIGA_MAC_VER_25 in
> rtl_test_hw_pad_bug as has been done for RTL_GIGA_MAC_VER_34 (see
> b423e9ae49d78ea3f53b131c8d5a6087aed16fd6).

I don't think it is necessary for RTL_GIGA_MAC_VER_25. I don't find any issue
about checksum or TSO for 8111d yet.
 
Best Regards,
Hayes
