From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH wireless-2.6 2/10] hostap: Include asm/io.h
Date: Tue, 22 Mar 2005 18:13:36 -0500
Message-ID: <4240A6A0.8090509@pobox.com>
References: <20050313001706.GA8253@jm.kir.nu> <20050313002940.GC8253@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Jouni Malinen <jkmaline@cc.hut.fi>
In-Reply-To: <20050313002940.GC8253@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jouni Malinen wrote:
> Include asm/io.h into hostap_{pci,plx}.c since this seems to be needed
> for ARM on Linux 2.6.x and this file is already included into
> hostap_cs.c anyway.
> 
> Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>

Patch is correct, but description is incorrect:

asm/io.h is a required include for any driver that uses the bus IO 
functions {in,out,read,write}[bwlq].  It's not just ARM, but instead is 
required for all platforms.

	Jeff
