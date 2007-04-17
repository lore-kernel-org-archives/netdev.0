From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 8338] New: NAT of TCP connections broken
Date: Tue, 17 Apr 2007 15:00:57 +0200
Message-ID: <4624C509.5020409@trash.net>
References: <200704162035.l3GKZlTI002693@fire-2.osdl.org> <20070416134828.5885b451.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>, ernisv@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:32872 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753931AbXDQNBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 09:01:22 -0400
In-Reply-To: <20070416134828.5885b451.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
>>On Mon, 16 Apr 2007 13:35:47 -0700 bugme-daemon@bugzilla.kernel.org wrote:
>>http://bugzilla.kernel.org/show_bug.cgi?id=8338
>>
>>I'm using my debian box for sharing internet connection. After update to 
>>debian's 2.6.20 kernel (and adjusting new kernel configuration for NAT) NAT of 
>>TCP connections stoped working, while ICMP and UDP is working (ping, traceroute 
>>and DNS). When trying to open web page on a PC from my LAN (tried with linux 
>>and winxp), it sends the request but is unable to receive correct response from 
>>any site. On the router PC www works ok. 
>>
>>I tried both new "Independent connection tracking" as well as "Dependent 
>>(obsolete) connection tracking" options with no luck.
>>
>>tcp_window_scaling setting seems to have no effect.


Please send packet dumps from both the incoming and outgoing interfaces.
