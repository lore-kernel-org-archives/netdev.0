From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 3/7] packet: rollover prepare: single return in
 packet_rcv_has_room
Date: Thu, 7 May 2015 13:49:27 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CB2F5E7@AcuExch.aculab.com>
References: <1430936837-22655-1-git-send-email-willemb@google.com>
 <1430936837-22655-4-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>
To: 'Willem de Bruijn' <willemb@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.192]:60808 "EHLO
	smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751050AbbEGNup convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 09:50:45 -0400
In-Reply-To: <1430936837-22655-4-git-send-email-willemb@google.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn
> Sent: 06 May 2015 19:27
> Convert
> 
>   if (x) {
>     A;
>     return y;
>   }
>   B;
>   return y;
> 
> Into
> 
>   if (x) {
>     A;
>   } else {
>     B;
>   }
> 
>   return y;
> 
> No other changes.

...

IMHO there is little benefit in the 'single return from function' style.
In general it just makes scan-reading of code more difficult (once you
see a 'return' you know then is no more relevant code) and hits the RH margin.

	David
