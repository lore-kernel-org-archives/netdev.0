From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8755] New: "ip -6 route change " behaves like
 "ip -6 route add"
Date: Sat, 14 Jul 2007 21:47:31 -0700
Message-ID: <20070714214731.baf38cb8.akpm@linux-foundation.org>
References: <bug-8755-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>, bugzilla@fire.lp0.eu
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:36555 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750980AbXGOErx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jul 2007 00:47:53 -0400
In-Reply-To: <bug-8755-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 14 Jul 2007 15:21:21 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8755
> 
>            Summary: "ip -6 route change " behaves like "ip -6 route add"
>            Product: Networking
>            Version: 2.5
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: IPV6
>         AssignedTo: yoshfuji@linux-ipv6.org
>         ReportedBy: bugzilla@fire.lp0.eu
> 
> 
> The "ip -6 route change" command behaves as though "ip -6 route add" was used.
> The source of iproute2 shows that "change" uses the "NLM_F_REPLACE" netlink
> flag only.
> 
> ip utility, iproute2-ss070313
> 
> Changing an existing route:
> # ip -6 r show 2002::/16
> 2002::/16 dev sit0  metric 1024  expires 4482618sec mtu 1480 advmss 7140
> hoplimit 4294967295
> # ip -6 r change 2002::/16 dev sit0 mtu 1280
> RTNETLINK answers: File exists
> 
> Adding a route using "change":
> # ip -6 r change 2002::/17 dev sit0 mtu 1280
> # ip -6 r show 2002::/17
> 2002::/17 dev sit0  metric 1024  expires 21334368sec mtu 1280 advmss 1220
> hoplimit 4294967295
> 
