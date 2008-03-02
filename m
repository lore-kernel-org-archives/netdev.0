From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: assertion (packets <= tp->packets_out) failed
Date: Sun, 2 Mar 2008 10:44:29 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0803021041560.17707@kivilampi-30.cs.helsinki.fi>
References: <2c0942db0803011510s5cfc30cbhee8ac9c1b849a2aa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel list <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Ray Lee <ray-lk@madrabbit.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43775 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752447AbYCBIoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2008 03:44:32 -0500
In-Reply-To: <2c0942db0803011510s5cfc30cbhee8ac9c1b849a2aa@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 1 Mar 2008, Ray Lee wrote:

> Wireless below is b43, wired interface (tg3) was disconnected. I run
> openvpn which uses a tun interface and regularly sends a heartbeat
> even when not in use. The trace appeared twice.
> 
> Likely unrelated but reporting just for completeness: about fifteen
> minutes after this the system oopsed when I told my wireless base
> station to switch from mixed B/G to just B. I'll be taking that up
> separately with the bcm43xx list.
> 
> Mar  1 11:06:37 phoenix kernel: [35251.208275] eth1: switched to short
> barker preamble (BSSID=00:16:01:d1:44:3e)
> Mar  1 11:06:37 phoenix kernel: [35251.320282] eth1: switched to long
> barker preamble (BSSID=00:16:01:d1:44:3e)
> Mar  1 11:08:28 phoenix kernel: [35274.396163] KERNEL: assertion
> (packets <= tp->packets_out) failed at net/ipv4/tcp_input.c (2139)
> Mar  1 11:08:29 phoenix kernel: [35274.406126] ------------[ cut here
> ]------------
> Mar  1 11:08:29 phoenix kernel: [35274.406132] WARNING: at
> net/ipv4/tcp_input.c:2506 tcp_ack+0xe3f/0x1b12()

Do people ever look into archives before posting? I'm a bit tired of point 
to the debug patch:

http://marc.info/?l=linux-kernel&m=120418703023153&w=2

-- 
 i.
