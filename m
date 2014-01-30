From: Andre Naujoks <nautsch2@gmail.com>
Subject: Re: [PATCH stable 3.11+] can: use private sk reference to detect
 originating socket
Date: Thu, 30 Jan 2014 09:32:58 +0100
Message-ID: <52EA0E3A.7080702@gmail.com>
References: <52E905C8.1060408@hartkopp.net>		 <1391007745.28432.36.camel@edumazet-glaptop2.roam.corp.google.com>		 <1391009406.28432.38.camel@edumazet-glaptop2.roam.corp.google.com>	 <1391010437.28432.39.camel@edumazet-glaptop2.roam.corp.google.com>	 <52E956E6.7090002@hartkopp.net> <1391025348.28432.63.camel@edumazet-glaptop2.roam.corp.google.com> <52E9675A.4070201@hartkopp.net> <52E96BDC.9070209@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <52E96BDC.9070209@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29.01.2014 22:00, schrieb Oliver Hartkopp:
> So here we are:
> 
> Introduced can_create_echo_skb() which creates a skb which is properly
> owned to be send back (echo'ed) into the network stack. 


I see no crashes with this and it works as expected.

You can add my:

Tested-by: Andre Naujoks <nautsch2@gmail.com>

Regards
  Andre
> 
> Regards,
> Oliver
> 

