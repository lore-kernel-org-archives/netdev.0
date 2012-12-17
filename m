From: "Vitaly E. Lavrov" <lve@guap.ru>
Subject: Re: [PATCH] bugfix: network namespace & device dummy
Date: Mon, 17 Dec 2012 21:25:29 +0400
Message-ID: <50CF5589.5000203@guap.ru>
References: <50CF1797.803@guap.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.guap.ru ([91.151.188.3]:27752 "EHLO mail.guap.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751917Ab2LQRZb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2012 12:25:31 -0500
Received: from [10.150.100.7] ([95.161.253.150])
	(user=lve@guap.ru mech=CRAM-MD5 bits=0)
	by mail.guap.ru (8.14.4/8.14.4) with ESMTP id qBHHPTp7016551
	for <netdev@vger.kernel.org>; Mon, 17 Dec 2012 21:25:29 +0400
In-Reply-To: <50CF1797.803@guap.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17.12.2012 17:01, V. Lavrov wrote:
> If container has a network device dummyX (with lxc.network.type = 
> phys), then it disappears from the system after you close the container.
> The patch returns the device dummyX to the initial network namespace 
> after container is closed.
Do not use this patch. Network devices such as "ifb" and "dummy" can 
re-create command "ip li add ..."

This feature should be documented in the LXC
