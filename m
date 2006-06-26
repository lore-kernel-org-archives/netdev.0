From: Andrey Savochkin <saw@swsoft.com>
Subject: Re: [patch 4/4] Network namespaces: playing and debugging
Date: Mon, 26 Jun 2006 23:34:34 +0400
Message-ID: <20060626233434.A4532@castle.nmd.msu.ru>
References: <20060626134945.A28942@castle.nmd.msu.ru> <20060626135250.B28942@castle.nmd.msu.ru> <20060626135427.C28942@castle.nmd.msu.ru> <20060626135537.D28942@castle.nmd.msu.ru> <449FF77D.3080707@fr.ibm.com> <20060626194339.D989@castle.nmd.msu.ru> <44A01995.20802@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	serue@us.ibm.com, haveblue@us.ibm.com, clg@fr.ibm.com,
	Andrew Morton <akpm@osdl.org>, dev@sw.ru, herbert@13thfloor.at,
	devel@openvz.org, sam@vilain.net, ebiederm@xmission.com,
	viro@ftp.linux.org.uk, Alexey Kuznetsov <alexey@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from castle.nmd.msu.ru ([193.232.112.53]:16909 "HELO
	castle.nmd.msu.ru") by vger.kernel.org with SMTP id S932956AbWFZTef
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jun 2006 15:34:35 -0400
To: Daniel Lezcano <dlezcano@fr.ibm.com>
In-Reply-To: <44A01995.20802@fr.ibm.com>; from "Daniel Lezcano" on Mon, Jun 26, 2006 at 07:29:57PM
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 26, 2006 at 07:29:57PM +0200, Daniel Lezcano wrote:
> >>>Do
> >>>	exec 7< /proc/net/net_ns
> >>>in your bash shell and you'll get a brand new network namespace.
> >>>There you can, for example, do
> >>>	ip link set lo up
> >>>	ip addr list
> >>>	ip addr add 1.2.3.4 dev lo
> >>>	ping -n 1.2.3.4
> >>>
> 
> Andrey,
> 
> I began to play with your patchset. I am able to connect to 127.0.0.1 
> from different namespaces. Is it the expected behavior ?
> Furthermore, I am not able to have several programs, running in 
> different namespaces, to bind to the same INADDR_ANY:port.
> 
> Will these features be included in the second patchset ?

Of course.
This patchset adds namespaces to routing code, which means that
you can define local IP addresses in each namespace independently.
But this first patchset doesn't include namespaces in socket lookup code.

	Andrey
