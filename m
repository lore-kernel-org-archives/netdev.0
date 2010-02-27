From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: TCP ACK loop with 2.6.33-rc6
Date: Sat, 27 Feb 2010 13:13:49 +0200 (EET)
Message-ID: <alpine.DEB.2.00.1002271313070.31669@melkinpaasi.cs.helsinki.fi>
References: <4B88FB88.3050902@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Simon Arlott <simon@fire.lp0.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59479 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965569Ab0B0LNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 06:13:50 -0500
In-Reply-To: <4B88FB88.3050902@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 27 Feb 2010, Simon Arlott wrote:

> Packet capture attached. Is it possible to tell which side is at fault?
> They are both responding to each other's ACK with another ACK at 400pps.
> 
> 10:32:28.991111 IP6 2001:8b0:ffea:0:205:b4ff:fe12:530.35545 > 2001:500:b::1.53: . ack 766 win 58 <nop,nop,timestamp 2411331059 251057709>
> 10:32:28.995046 IP6 2001:500:b::1.53 > 2001:8b0:ffea:0:205:b4ff:fe12:530.35545: . ack 1 win 1559

Why only a single ends talks with timestamps?!?!?

-- 
 i.
