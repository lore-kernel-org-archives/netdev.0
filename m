From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [RFC/PATCH] network configs: disconnect network options from drivers
Date: Thu, 31 Mar 2005 20:52:26 +0200
Message-ID: <20050331185226.GA8146@mars.ravnborg.org>
References: <20050330234709.1868eee5.randy.dunlap@verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ioe-lkml@axxeo.de, matthew@wil.cx, lkml <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Randy.Dunlap" <randy.dunlap@verizon.net>
Content-Disposition: inline
In-Reply-To: <20050330234709.1868eee5.randy.dunlap@verizon.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 30, 2005 at 11:47:09PM -0800, Randy.Dunlap wrote:
> 
> - some Networking options need to be qualified with CONFIG_NET
You can something along the lines os:

menu "Networking options and protocols"
  
config NET
	bool "Networking support"
	default y

if NET

...

menu "Network device support"
...
endmenu

...

endif
endmenu

Then everything wrapped in between if NET/endif is dependent on NET
without stating this explicitly.
You will alos have the menu nice indented.

	Sam
