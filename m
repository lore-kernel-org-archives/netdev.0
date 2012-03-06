From: Glauber Costa <glommer@parallels.com>
Subject: Re: [PATCH 2/3] tcp: Initial repair mode
Date: Tue, 6 Mar 2012 17:11:47 +0400
Message-ID: <4F560D13.4000404@parallels.com>
References: <4F55DEDE.1090602@parallels.com> <4F55DF12.6030001@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:48544 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751757Ab2CFNNC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2012 08:13:02 -0500
In-Reply-To: <4F55DF12.6030001@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/06/2012 01:55 PM, Pavel Emelyanov wrote:
> This includes (according the the previous description):
>
> * TCP_REPAIR sockoption
>
> This one just puts the socket in/out of the repair mode.
> Allowed for CAP_SYS_ADMIN and for closed/establised sockets only.
> When repair mode is turned off and the socket happens to be in
> the established state the window probe is sent to the peer to
> 'unlock' the connection.

Why not CAP_NET_ADMIN, or something similar?
