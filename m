From: David Brownell <david-b@pacbell.net>
Subject: Re: [RFC] updated Patch to option HSO driver to the kernel
Date: Mon, 21 Apr 2008 15:58:15 -0700
Message-ID: <200804211558.15448.david-b@pacbell.net>
References: <20080417214719.GF17664@kroah.com> <20080421184157.106603602C8@adsl-69-226-248-13.dsl.pltn13.pacbell.net> <480D0F5B.9010808@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Network development list <netdev@vger.kernel.org>
To: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp119.sbc.mail.sp1.yahoo.com ([69.147.64.92]:45227 "HELO
	smtp119.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753914AbYDUW6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 18:58:18 -0400
In-Reply-To: <480D0F5B.9010808@teltonika.lt>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 21 April 2008, Paulius Zaleckas wrote:
> 		To make this interface work you have to
> send AT command with APN and optionally with PAP/CHAP username and password.
> Then you call AT command witch initiates PPP with basestation and begins
> to send/receive traffic on this pseudo ethernet interface... Actually it
> still needs one more AT command to get your IP and DNS addresses.
> Then you do: ifconfig hso0 xxx.xxx.xxx.xxx netmask 255.255.255.255 up
> And then you have to write DNS addresses (got through AT interface) to
> the /etc/resolv.conf. Now you have a working internet connection!

Hardly a general purpose device, then ... not even the model I'm
used to seeing from a DSL or cable modem.  Presumably you have some
tool that runs on Linux to set up links like that.


> So... I don't see any chance to do multicasting or broadcasting here...

Well, some folk would want IP multicast for video support, but that's
a different issue.

- Dave

> P.S. Pseudo ethernet means that it receives bare IP packet from USB device,
> adds dummy ethernet header and sends it for further processing to kerne

