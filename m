From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [RFC/PATCH] network configs: disconnect network options from
 drivers
Date: Thu, 31 Mar 2005 12:02:13 -0800
Message-ID: <424C5745.7020501@osdl.org>
References: <20050330234709.1868eee5.randy.dunlap@verizon.net> <20050331185226.GA8146@mars.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ioe-lkml@axxeo.de, matthew@wil.cx,
	lkml <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com,
	hadi@cyberus.ca, cfriesen@nortel.com, tgraf@suug.ch
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261712AbVCaUDQ@vger.kernel.org>
To: Sam Ravnborg <sam@ravnborg.org>
In-Reply-To: <20050331185226.GA8146@mars.ravnborg.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sam Ravnborg wrote:
> On Wed, Mar 30, 2005 at 11:47:09PM -0800, Randy.Dunlap wrote:
> 
>>- some Networking options need to be qualified with CONFIG_NET
> 
> You can something along the lines os:
> 
> menu "Networking options and protocols"
>   
> config NET
> 	bool "Networking support"
> 	default y
> 
> if NET
> 
> ...
> 
> menu "Network device support"
> ...
> endmenu
> 
> ...
> 
> endif
> endmenu
> 
> Then everything wrapped in between if NET/endif is dependent on NET
> without stating this explicitly.
> You will alos have the menu nice indented.

Yes, sounds good, thanks.

And I'll look into Thomas's suggestions.

Other than "sounds good," are there some comments on:

a.  leaving IrDA and Bluetooth subsystem (with drivers) where they
     are, which is under "Network options and protocols"
	(I really don't want to split their drivers away from their
	subsystem, just to put them under Network driver support.)

b.  leaving SLIP, PPP, and PLIP where they are under Network driver
     support, even though they say that they are "protocols" ?

Any others?

Thanks,
-- 
~Randy
