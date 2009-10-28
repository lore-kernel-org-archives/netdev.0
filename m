From: <Narendra_K@Dell.com>
Subject: RE: [PATCH] udev: create empty regular files to represent net interfaces
Date: Thu, 29 Oct 2009 00:45:06 +0530
Message-ID: <EDA0A4495861324DA2618B4C45DCB3EE589654@blrx3m08.blr.amer.dell.com>
References: <20091016214024.GA10091@ldl.fc.hp.com> <20091022063619.GB6321@ldl.fc.hp.com> <20091027205551.GA31963@auslistsprd01.us.dell.com> <ac3eb2510910280123g3c0e3d95wb38a239238906027@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <dannf@hp.com>, <linux-hotplug@vger.kernel.org>,
	<netdev@vger.kernel.org>, <Jordan_Hargrave@Dell.com>,
	<Charles_Rose@Dell.com>, <bhutchings@solarflare.com>
To: <kay.sievers@vrfy.org>, <Matt_Domsch@Dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <ac3eb2510910280123g3c0e3d95wb38a239238906027@mail.gmail.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>That all sounds very much like something which will hit us 
>back some day. I'm not sure, if udev should publish such dead 
>text files in /dev, it does not seem to fit the usual 
>APIs/assumptions where /sys and /dev match, and libudev 
>provides access to both. It all sounds more like a database 
>for a possible netdevname library, which does not need to be 
>public in /dev, right?

The char device nodes under /dev/netdev/ do seem to adhere to the
assumption of what is there under /sys and /dev match.

With regards,
Narendra K
