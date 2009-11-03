From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14451] New: b44 BCM4401 immediate disconnect
 and power down after ip assignment
Date: Tue, 3 Nov 2009 15:23:08 -0800
Message-ID: <20091103152308.d17ed779.akpm@linux-foundation.org>
References: <bug-14451-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	andreas@schipplock.de
To: Gary Zambrano <zambrano@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48247 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751824AbZKCXXh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 18:23:37 -0500
In-Reply-To: <bug-14451-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 21 Oct 2009 07:38:13 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14451
> 
>            Summary: b44 BCM4401 immediate disconnect and power down after
>                     ip assignment
>            Product: Drivers
>            Version: 2.5
>     Kernel Version: 2.6.31.4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Network
>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>         ReportedBy: andreas@schipplock.de
>         Regression: No
> 
> 
> Hi,
> I compiled the linux kernel 2.6.31.4 and after "dhcpcd" wanted to assign an ip,
> it worked for 500ms and I then got the following message being repeated a _lot_
> in dmesg:
> 
> b44: eth0: powering down PHY
> b44: eth0: Link is down.
> b44: eth0: Link is up at 100 Mbps, full duplex.
> b44: eth0: Flow control is off for TX and off for RX.
> b44: eth0: powering down PHY
> b44: eth0: Link is down.
> b44: eth0: Link is up at 100 Mbps, full duplex.
> b44: eth0: Flow control is off for TX and off for RX.
> 
> These messages repeat endlessly and I can't establish a connection. 
> 
> The exact name of the ethernet controller is: "08:00.0 Ethernet controller:
> Broadcom Corporation BCM4401-B0 100Base-TX (rev 02)" regarding lspci output.
> 
> When I execute "ifconfig" every 500ms I can see that the device "eth0" gets a
> valid ip but the next time I execute ifconfig the ip is already "gone" and I
> again get the the messages posted above in dmesg. 
> 
> I first thought was that I have a media problem so I replaced all my wires but
> the problem still exists and the problem doesn't appear on the 2.6.28.x kernel
> which I ran before. I even installed linux mint in a hurry to see if it's
> really not a hardware issue and it worked there without a problem (using kernel
> 2.6.28-11, that's how they call it).
> 
> I've got no further idea. I created three different config files from scratch
> using menuconfig. In the end I even thought other modules are conflicting and I
> adapted the config so it only fits for my specific hardware which gave me some
> good boot time but no success regarding the bcm4401 issue. 
> 
> Any help is appreciated. 
> 

