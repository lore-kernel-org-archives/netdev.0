From: Gustavo Padovan <gustavo@padovan.org>
Subject: Re: [PATCH 1/2] Bluetooth: notify userspace of security level change
Date: Sun, 13 May 2012 03:22:24 -0300
Message-ID: <20120513062224.GC15956@joana>
References: <20120512190900.GA15956@joana>
 <1336849910-29064-1-git-send-email-gustavo@padovan.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:57822 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392Ab2EMGWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 May 2012 02:22:31 -0400
Content-Disposition: inline
In-Reply-To: <1336849910-29064-1-git-send-email-gustavo@padovan.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

* Gustavo Padovan <gustavo@padovan.org> [2012-05-12 16:11:49 -0300]:

> When the userspace request a security level change it needs to be notified
> of when the change is complete.
> This patch make the socket non writable while the security request is
> ongoing. If it succeeds POLL_OUT is emitted, otherwise the channel is
> disconnected.

I just sent a second version of this patches that includes comments Johan made
in the last e-mail for better understanding of what the problem really is.

	Gustavo
