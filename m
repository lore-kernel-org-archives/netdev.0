From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [ofa-general] Re: dst_ifdown breaks infiniband?
Date: Mon, 19 Mar 2007 12:20:09 +0300
Message-ID: <20070319092009.GA9387@ms2.inr.ac.ru>
References: <20070318155532.GG7958@mellanox.co.il> <20070318191238.GA20518@ms2.inr.ac.ru> <20070318202559.GD11078@mellanox.co.il> <m3tzwi8a20.fsf@maxwell.lnxi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>,
	netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	general@lists.openfabrics.org
To: "Eric W. Biederman" <ebiederman@lnxi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:54253 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752423AbXCSJUY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Mar 2007 05:20:24 -0400
Content-Disposition: inline
In-Reply-To: <m3tzwi8a20.fsf@maxwell.lnxi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Well I don't think the loopback device is currently but as soon
> as we get network namespace support we will have multiple loopback
> devices and they will get unregistered when we remove the network
> namespace.

There is no logical difference. At the moment when namespace is gone
there is nobody who can hold unrevokable references to this loopback.

Alexey
