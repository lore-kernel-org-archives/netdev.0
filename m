From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Invalid truesize messages since 2.6.25
Date: Tue, 22 Jul 2008 12:43:12 +0100
Message-ID: <20080722114311.GQ10471@solarflare.com>
References: <3C59DB883F7B0B4D8096010D45ACCD13C73AFA@exch.facton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Beschorner Daniel <Daniel.Beschorner@facton.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.mbr-roch.zen.net.uk ([212.23.3.140]:33725 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751121AbYGVLn1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 07:43:27 -0400
Content-Disposition: inline
In-Reply-To: <3C59DB883F7B0B4D8096010D45ACCD13C73AFA@exch.facton.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Beschorner Daniel wrote:
> Since 2.6.25 we rarely see these messages:
> 
> SKB BUG: Invalid truesize (408) len=198, sizeof(sk_buff)=216
> 
> Yesterday I saw it the first time after a runtime of one week with
> 2.6.26.
> The box is web server / IPSEC gateway.
> Obviously nothing seems to be affected by the message but <= 2.6.24 no
> messages appeared.

Invalid truesize can be caused by bugs in many different places.  So it
might be helpful to say which driver(s) and any unusual network protocol
or filter you are using.

Ben.
