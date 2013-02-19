From: "J. K. Cliburn" <jcliburn@gmail.com>
Subject: Re: Fw: [Bug 54021] New: No internet with kernel 3.7 or 3.8 with
 LAN
Date: Tue, 19 Feb 2013 07:13:10 -0600
Message-ID: <51237A66.8030008@gmail.com>
References: <20130218220552.4d54c9a9@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chris Snook <chris.snook@gmail.com>, netdev@vger.kernel.org,
	nic-devel@qca.qualcomm.com, "Huang, Xiong" <xiong@qca.qualcomm.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f52.google.com ([209.85.128.52]:48819 "EHLO
	mail-qe0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757000Ab3BSNNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 08:13:13 -0500
Received: by mail-qe0-f52.google.com with SMTP id 6so3030835qeb.11
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2013 05:13:12 -0800 (PST)
In-Reply-To: <20130218220552.4d54c9a9@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Xiong,

Can you please investigate this atl1c issue?

Jay

On 02/19/2013 12:05 AM, Stephen Hemminger wrote:
> Also, in link it references the devices
>
> $ lspci -nnk | grep -i net -A2
> 01:00.0 Ethernet controller [0200]: Atheros Communications Inc. AR8152 v1.1 Fast Ethernet [1969:2060] (rev c1)
> 	Subsystem: Acer Incorporated [ALI] Device [1025:0349]
> 	Kernel driver in use: atl1c
> --
> 02:00.0 Network controller [0280]: Atheros Communications Inc. AR9285 Wireless Network Adapter (PCI-Express) [168c:002b] (rev 01)
> 	Subsystem: Lite-On Communications Inc Device [11ad:6631]
> 	Kernel driver in use: ath9k
>
> Begin forwarded message:
>
> Date: Sun, 17 Feb 2013 05:38:37 -0800
> From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
> To: "stephen@networkplumber.org" <stephen@networkplumber.org>
> Subject: [Bug 54021] New: No internet with kernel 3.7 or 3.8 with LAN
>
>
> https://bugzilla.kernel.org/show_bug.cgi?id=54021
>
>             Summary: No internet with kernel 3.7 or 3.8 with LAN
>             Product: Networking
>             Version: 2.5
>      Kernel Version: since 3.7
>            Platform: All
>          OS/Version: Linux
>                Tree: Mainline
>              Status: NEW
>            Severity: normal
>            Priority: P1
>           Component: IPV4
>          AssignedTo: shemminger@linux-foundation.org
>          ReportedBy: david.erbs@gmail.com
>          Regression: No
>
>
> Hello since kernel update 3.7 or 3.8 I have no internet connection with LAN,
> wlan is working very well, with lan my internet connection is working for 5
> minutes, then internet is not working anymore. I have to unplug the cable and
> the i have to plug it again - so it will work 5 minutes.....
>
> I have a netbook (acer aspire one d255)
>
>
> With kernel 3.5x everything is working fine.
>
> Problem is reported here (German)
>
> http://forum.ubuntuusers.de/topic/internet-verbindung-bricht-ab/
>
> If you need more information, feel free to ask
>
>
> kind regards
>
