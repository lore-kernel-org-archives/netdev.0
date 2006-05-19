From: Brice Goglin <brice@myri.com>
Subject: Re: [PATCH 3/4] myri10ge - Driver core
Date: Fri, 19 May 2006 16:39:50 +0200
Message-ID: <446DD8B6.4060102@myri.com>
References: <20060517220218.GA13411@myri.com> <20060517220608.GD13411@myri.com> <200605180108.32949.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gallatin@myri.com,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:48354 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S932321AbWESOkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 May 2006 10:40:11 -0400
To: Arnd Bergmann <arnd@arndb.de>
In-Reply-To: <200605180108.32949.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> dev_err?
>   
[...]

> Could probably use dev_printk.
>   

When the interface name is known, we prefer having the message look like
"myri10ge: eth2: something" since it might be easier to read than
""myri10ge: 00005:000e: something". The administrator usually knows the
name of the network interface better than its bus ID.

Brice

