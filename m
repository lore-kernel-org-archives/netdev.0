From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: RFC new ethtool command
Date: Wed, 02 Mar 2005 00:54:29 -0500
Message-ID: <42255515.70804@pobox.com>
References: <3a958240e12af10ef6777f908abfe682@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>
To: Andy Fleming <afleming@freescale.com>
In-Reply-To: <3a958240e12af10ef6777f908abfe682@freescale.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen guessed right.  We don't need to add yet another "black hole" 
(a.k.a. untyped / dynamic) userland interface.

One of two directions is suggested:

* Create a generalized interface, and add new ethtool commands.

* Create a driver-specific ioctl, and submit a patch to userland ethtool 
which supports this.  Driver-specific / device-specific code in userland 
ethtool is acceptable.

	Jeff
