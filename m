From: mysql.jorge@decimal.pt
Subject: Re: [BUG 12364] Re: HTB - very bad precision? HFSC works fine!
     2.6.28
Date: Thu, 8 Jan 2009 10:34:23 -0000 (WET)
Message-ID: <2020.192.168.1.3.1231410863.squirrel@webmail.decimal.pt>
References: <20090108094231.GD4496@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Denys Fedoryschenko" <denys@visp.net.lb>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrly01.isp.novis.pt ([195.23.133.211]:57946 "EHLO
	mailrly01.isp.novis.pt" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751010AbZAHKeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 05:34:04 -0500
In-Reply-To: <20090108094231.GD4496@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GSO Was on.
So i changed it to off.
---
ethtool -K eth0 gso off
---

lira:~# ethtool -h|grep -i version
ethtool version 6

but still not shaping OK, now i'm trying with 10Kbit, the value goes down
to 1/2, sometimes 3Kbit/sec





> On 08-01-2009 00:42, mysql.jorge@decimal.pt wrote:
>> Is there anyway to debug this?
>
> Could you try: ethtool -k eth0
> with quite fresh ethtool, and to turn off GSO etc., if it's on?
>
> Jarek P.
>


