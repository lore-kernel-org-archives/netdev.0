From: Kristof Provost <Kristof@sigsegv.be>
Subject: Re: TCP checksum error on local device
Date: Wed, 9 Jul 2008 15:10:20 +0000
Message-ID: <20080709151019.GG27741@nereid>
References: <9a6873fa0807090734ge7ef12lf09e78db44ba77f5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Kevin Spiteri <kspiteri@ieee.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhineheart.priorweb.be ([213.193.229.215]:56183 "HELO
	rhineheart.priorweb.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1759960AbYGIPGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 11:06:37 -0400
Content-Disposition: inline
In-Reply-To: <9a6873fa0807090734ge7ef12lf09e78db44ba77f5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2008-07-09 16:34:32 (+0200), Kevin Spiteri <kspiteri@ieee.org> wrote:
> When I send TCP data from localhost to localhost (either on 127.0.0.1
> or on the public IP of the machine), the TCP checksum is wrong.
> 
I suspect this is intended and expected behaviour. The checksum is quite
useless as the packet never travels over the network and can't be
corrupted. 

The transmit code in net/ipv4/ip_output.c seems to mark packets for the
loopback interface with CHECKSUM_UNNECESSARY.

I guess the connection over loopback still carries the data like you'd
expect right?

Kristof

