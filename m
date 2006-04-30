From: md@Linux.IT (Marco d'Itri)
Subject: VLAN subinterfaces, bridges and udev
Date: Sun, 30 Apr 2006 16:29:29 +0200
Message-ID: <20060430142929.GA8901@wonderland.linux.it>
Reply-To: netdev@vger.kernel.org, md@Linux.IT
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from attila.bofh.it ([213.92.8.2]:36304 "EHLO attila.bofh.it")
	by vger.kernel.org with ESMTP id S1751136AbWD3OdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2006 10:33:09 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Please Cc me, I am not subscribed to netdev.]

Can I rely on the presence of the $DEVPATH/driver symlink (e.g.
/sys/class/net/eth0/driver) to check if a network interface is a "real"
device insteaf of a VLAN or a bridge?

----- Forwarded message from Marco d'Itri <md@Linux.IT> -----

To: linux-hotplug-devel@lists.sourceforge.net
Subject: VLAN subinterfaces
From: Marco d'Itri <md@Linux.IT>

I wrote a script to handle persistent rules for network interfaces, but
I noticed that VLAN subinterfaces have the same MAC address of the
parent interface and I could not find in sysfs anything evident which I
could use in a rule. The only difference I noticed is that the VLAN
subinterfaces lack the device and drivers symlinks.
This problem affects anybody using VLANs, is there a good solution?

-- 
ciao,
Marco

----- End forwarded message -----
----- Forwarded message from Marco d'Itri <md@Linux.IT> -----

To: linux-hotplug-devel@lists.sourceforge.net
Subject: Re: VLAN subinterfaces
From: Marco d'Itri <md@Linux.IT>

On Apr 23, Marco d'Itri <md@Linux.IT> wrote:

> I wrote a script to handle persistent rules for network interfaces, but
> I noticed that VLAN subinterfaces have the same MAC address of the
> parent interface and I could not find in sysfs anything evident which I
> could use in a rule. The only difference I noticed is that the VLAN
> subinterfaces lack the device and drivers symlinks.
> This problem affects anybody using VLANs, is there a good solution?
Another user (Debian bug #365248) reported that this applies to bridges
too. Is adding DRIVER=="?*" to the rules the correct workaround?

-- 
ciao,
Marco


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
Linux-hotplug-devel mailing list  http://linux-hotplug.sourceforge.net
Linux-hotplug-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/linux-hotplug-devel

----- End forwarded message -----

-- 
ciao,
Marco
