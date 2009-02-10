From: "=?iso-8859-15?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: pseudo interface with different hwaddr
Date: Tue, 10 Feb 2009 13:43:49 +0200
Message-ID: <200902101343.49743.remi.denis-courmont@nokia.com>
References: <20090210112508.GA16497@piper.oerlikon.madduck.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev discussion list <netdev@vger.kernel.org>
To: ext martin f krafft <madduck@madduck.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:26129 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443AbZBJLoZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 06:44:25 -0500
In-Reply-To: <20090210112508.GA16497@piper.oerlikon.madduck.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 10 February 2009 13:25:08 ext martin f krafft, you wrote:
> I have not yet come up with a way to solve this, but I was thinking
> that the most elegant would probably be some sort of pseudo
> interface that I could atach to eth0, such that pseudo0 would behave
> just like a real network interface to the kernel and software, while
> using eth0 to transmit frames from a different MAC. With eth0
> configured promisc, it would receive all frames, but let only those
> to its hwaddr through (unless it were itself configured promisc).

Wouldn't macvlan solve this?


--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D

