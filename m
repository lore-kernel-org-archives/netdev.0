From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: Re: [PATCH net] net: poll tx timeout only on active tx queues
Date: Fri, 1 Jul 2016 04:50:10 +0000
Message-ID: <CO2PR11MB00889A8F46E66124C99E43DE97250@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1467295085-9204-1-git-send-email-saeedm@mellanox.com>
 <1467296892.11238.24.camel@edumazet-glaptop3.roam.corp.google.com>,<CALzJLG-pjeZnOQ3FfZMLCz5KC-eXWWrTZS4yNi-+UYY=2T549A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	"Tom Herbert" <tom@herbertland.com>,
	Mohamad Haj Yahia <mohamad@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0121.outbound.protection.outlook.com ([104.47.42.121]:44252
	"EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751036AbcGAFEQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 01:04:16 -0400
In-Reply-To: <CALzJLG-pjeZnOQ3FfZMLCz5KC-eXWWrTZS4yNi-+UYY=2T549A@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> currently all the device driver call=A0 netif_tx_start_all_queues(dev=
)
> on open to W/A this issue. which is strange since only
> real_num_tx_queues are active.

You could also argue that netif_tx_start_all_queues() should
only enable the real_num_tx_queues.
[Although that would obviously cause all drivers to reach the
'problem' you're currently fixing].
