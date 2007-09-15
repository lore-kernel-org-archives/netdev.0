From: "L F" <lfabio.linux@gmail.com>
Subject: Re: e1000 driver and samba
Date: Fri, 14 Sep 2007 20:37:26 -0400
Message-ID: <780b6f780709141737w4e17f0a8r944555f27f7344dd@mail.gmail.com>
References: <780b6f780709131904j41148fb4p827e87530b15d6e9@mail.gmail.com>
	 <46EAC25B.2060404@intel.com>
	 <780b6f780709141140l1fd586c9p2aa8efe6ed803d38@mail.gmail.com>
	 <46EAF644.1040006@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.179]:7569 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760201AbXIOAh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 20:37:27 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1152549wah
        for <netdev@vger.kernel.org>; Fri, 14 Sep 2007 17:37:26 -0700 (PDT)
In-Reply-To: <46EAF644.1040006@intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> can you describe your setup a bit more in detail? you're writing from a linux
> client to a windows smb server? or even to a linux server? which end sees the
> connection drop? the samba server? the samba linux client?
Certainly.
I have a LAN, with two switches in a stack. There currently are 7
WinXP clients and one linux machine. The linux machine acts as a samba
server and as a firewall/gateway.
The two ports of the PRO/1000 in the linux box are connected to the
LAN (eth4) and to a Comcast modem (eth3) respectively. Shorewall 3.4.5
is running on the linux machine, with a strong firewall + NAT setup.
Further, the linux machine currently has a tap device bridged into the
LAN side, for virtualbox.
Therefore, eth3 is a plain ethernet interface. br0, on the lan side,
is tap0 + eth4.
If I get any client on the LAN side, I can read from the linux box
without a problem. However, if I attempt to write to the linux box
from a LANside client, it will fail. If traffic is low, the failures
are sporadic. If traffic is high (large file and/or multiple incoming
files) the failure is guaranteed, either in 'delayed write fail' mode
on the client or in silent corruption of the file (much worse). If
read/write activity is combined, for instance when I unzip a zip
archive to its own directory, failure is guaranteed and rapid, with a
'delayed write fail' on the client after 50MB or so.
I can post .config and anything else you may want if you require it. I
tried changing cable as you suggested with little success. I'll try
changing switch port, just to cover all bases.
>
> Auke
>
