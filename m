From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 14794] New: IP address assigned by DHCP is
 dropped after ~40 seconds
Date: Wed, 16 Dec 2009 15:47:13 -0800
Message-ID: <20091216154713.f082e7cf.akpm@linux-foundation.org>
References: <bug-14794-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, nm127@freemail.hu
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:42908 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751093AbZLPXra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 18:47:30 -0500
In-Reply-To: <bug-14794-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

A 2.6.31 -> 2.6.32 regression.

On Sun, 13 Dec 2009 08:59:48 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=14794
> 
>            Summary: IP address assigned by DHCP is dropped after ~40
>                     seconds
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.32
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV4
>         AssignedTo: shemminger@linux-foundation.org
>         ReportedBy: nm127@freemail.hu
>         Regression: Yes
> 
> 
> Created an attachment (id=24165)
>  --> (http://bugzilla.kernel.org/attachment.cgi?id=24165)
> Wireshark log while acquiring IP address
> 
> The IP address which was assigned by DHCP is dropped and the address
> 169.254.123.251 is set. This happens on Clevo D4J model D410J with 2.6.32, but
> works correctly with 2.6.31.
> 
> Steps to reproduce:
> 1. Boot the system
> 2. In an xterm window execute the following command to see the actual IP
> address settings:
>    while true; do clear; date; /sbin/ifconfig; sleep 1; done
> 3. Unplug the network cable for some seconds: the IP address should be gone
> 4. Plug the network cable.
> 5. After about 10 seconds the IP address 192.168.1.64 assigned by DHCP is
> visible
> 6. After about 50 seconds (counting from the plug of the network cable) no IP
> address is assigned
> 7. After about 65 seconds (counting from the plug of the network cable) the IP
> address 169.254.123.251 is assigned. This IP address will not work on this
> network.
> 
> I run Wireshark during the whole process, see the attached log file.
> Packet 25..28: DHCP address is fetched.
> Packet 63: DHCP release: this should not happen
> 


