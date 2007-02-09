From: "Pascal Terjan" <pterjan@gmail.com>
Subject: Re: [Bugme-new] [Bug 7962] New: oops in port_carrier_check
Date: Fri, 9 Feb 2007 19:50:17 +0100
Message-ID: <e8ca35370702091050naaa9669n2d19fec4b429c07f@mail.gmail.com>
References: <20070207140916.088b1073@oldman>
	 <20070209074211.GA1631@ff.dom.local> <20070209095204.7f43a964@oldman>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@o2.pl>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.224]:13941 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946771AbXBISuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 13:50:17 -0500
Received: by nz-out-0506.google.com with SMTP id s1so882014nze
        for <netdev@vger.kernel.org>; Fri, 09 Feb 2007 10:50:17 -0800 (PST)
In-Reply-To: <20070209095204.7f43a964@oldman>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2007/2/9, Stephen Hemminger <shemminger@linux-foundation.org>:
> The carrier_check is canceled by removal of port from bridge.
> Perhaps there is something broken in rcu assumptions under Qemu

If that can help:
I started /stopped qemu several times. Maybe I started /stopped qemu
several times as I was testing new PXE support in qemu with different
virtual nic. Each time, a tun device was created by qemu at startup
and added to the bridge, and destroyed on exit.
