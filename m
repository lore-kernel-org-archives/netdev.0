From: Kumar Gala <galak@kernel.crashing.org>
Subject: status of route matching work?
Date: Tue, 14 Nov 2006 15:08:25 -0600
Message-ID: <F8900C78-45E3-4818-B7EA-DF14516CF876@kernel.crashing.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nommos.sslcatacombnetworking.com ([67.18.224.114]:32232 "EHLO
	nommos.sslcatacombnetworking.com") by vger.kernel.org with ESMTP
	id S966059AbWKNVIN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Nov 2006 16:08:13 -0500
To: Thomas Graf <tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas,

I came across this comment in DaveM's blog:

"Next he described a way to do route matching based upon branching  
rules with a "GOTO" operation. Only forward GOTOs would be allowed in  
the tree in order to prevent loops, but this would allow to match on  
many key components and allow a high level of rule sharing.

One nice consequence of Thomas's work is that we can force packets  
for a local address to still go over a real ethernet device. Some  
people do this for testing and the current kernel cannot do this.  
Continually a very ugly patch keeps getting submitted which allowed  
this but broke a lot of other things. Thomas's ideas allow this to be  
supported cleanly."

And was wondering what the status of this work was.  I'm interested  
in being able to force packets for a local address out a real  
ethernet device.

thanks

- kumar
