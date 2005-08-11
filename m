From: "Leonid Grossman" <Leonid.Grossman@neterion.com>
Subject: RE: [ANNOUNCE] Experimental Driver for Neterion/S2io 10GbE Adapters
Date: Thu, 11 Aug 2005 15:40:42 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77057419@nekter>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Cc: <netdev@oss.sgi.com>, <davem@davemloft.net>, <ak@muc.de>
Return-path: <netdev-bounce@oss.sgi.com>
Content-class: urn:content-classes:message
To: "Jeff Garzik" <jgarzik@pobox.com>, <alex@neterion.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Jeff,

Thanks for remembering about the submission. My assumption was that the
submission did not get a consensus and died quietly :-), so we stopped
maintenance on the experimental driver several weeks ago and pulled it
from the ftp site.

I guess the original idea behind developing the "experimental" driver
was to eventually use it as a replacement for the "s2io" driver in the
kernel, mainly for the maintenance reasons - since "experimental" driver
shares hardware-oriented code with other Neterion drivers, our team
could run mature network test suites in other Operating Systems and
indirectly find/fix issues in Linux driver in a very efficient fashion.

This benefit seemed to be outweighed by other concerns that some of you
guys raised on the list. 
In a long run (as 10GbE Xframe cards get shipped in volumes and the
patches start coming in from the community), these concerns may be
valid, so we have decided to stay with "s2io" driver as our production
code.

Leonid  

> -----Original Message-----
> From: netdev-bounce@oss.sgi.com 
> [mailto:netdev-bounce@oss.sgi.com] On Behalf Of Jeff Garzik
> Sent: Thursday, August 11, 2005 10:48 AM
> To: alex@neterion.com
> Cc: netdev@oss.sgi.com; davem@davemloft.net; ak@muc.de
> Subject: Re: [ANNOUNCE] Experimental Driver for Neterion/S2io 
> 10GbE Adapters
> 
> Alex Aizman wrote:
> > This is our 2nd attempt to submit "xge", the experimental 
> driver for 
> > Neterion, Inc (formerly S2io, Inc) family of 10GbE adapters.
> 
> Can you send a link to the latest version of this driver, for review?
> 
> 	Jeff
> 
> 
> 
> 
> 
