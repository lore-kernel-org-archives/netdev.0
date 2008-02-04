From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: [NET_SCHED 00/04]: External SFQ classifiers/flow classifier
Date: Mon, 04 Feb 2008 10:25:20 -0800
Message-ID: <47A75890.6090704@fatooh.org>
References: <20080131175758.25151.20370.sendpatchset@localhost.localdomain> <47A4FB81.80700@fatooh.org> <47A74FEE.6080103@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:55222 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753420AbYBDSZX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Feb 2008 13:25:23 -0500
In-Reply-To: <47A74FEE.6080103@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy wrote:
> You're missing protocol, handle etc. Try something like this:
> 
> tc filter add dev eth0 protocol ip pref 1 parent 1: handle 1 \ 
> 
>          flow hash keys dst divisor 1024

Thanks, the kernel accepts that. I guess I understand tc filter usage
less than I thought I did.... Time to teach myself better.

-Corey
