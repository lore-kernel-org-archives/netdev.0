From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: b44 module problems
Date: Mon, 28 Jul 2003 12:56:31 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030728095631.GA6946@ee.oulu.fi>
References: <20030728114302.1cbb6f70.zagarna@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Antonio Dolcetta <zagarna@yahoo.com>
Content-Disposition: inline
In-Reply-To: <20030728114302.1cbb6f70.zagarna@yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Jul 28, 2003 at 11:43:02AM +0200, Antonio Dolcetta wrote:
> 1 ) boot and load the module, don't plug in the ethernet cable
> 2 ) try to configure the card via dhcp, it times out
> 3 ) rmmod b44
> at this point I get cpu at 90% 
> new istances of lsmod and rmmod hang during execution
> i get the following kernel events:
> unregister_netdevice: waiting for eth0 to become free. Usage count = 1
> every few seconds, 
> is there any more testing i can do for you?
> 
> the module works flawlessly otherwise
> thank you
Hi

You're not trying to use ipv6 or have the module loaded by any chance? When working
on the driver I had similar problems with rmmod on 2.5 when the ipv6 module
was loaded, without it unloading worked just fine (if I understood correctly,
this is a known problem with all ethernet drivers). In any case I'll try 
reproducing the problem when I get back home.
