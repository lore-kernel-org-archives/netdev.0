From: Joseph Jezak <josejx@gentoo.org>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Tue, 27 Jun 2006 12:52:17 -0400
Message-ID: <44A16241.9000009@gentoo.org>
References: <20060626212547.GE30706@tuxdriver.com> <200606271530.06749.mb@bu3sch.de> <44A13C81.2050503@garzik.org> <200606271725.26037.mb@bu3sch.de> <44A158EB.90406@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from oscar.berkshire.net ([12.111.80.68]:11950 "EHLO
	oscar.berkshire.net") by vger.kernel.org with ESMTP
	id S1161200AbWF0Qw0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 12:52:26 -0400
Received: from [192.168.1.220] (mdm231-229.arc12.atlnga1.dasdial.com [199.232.231.229])
	by oscar.berkshire.net (8.12.8+Sun/8.12.2) with ESMTP id k5RGpxpJ003620
	for <netdev@vger.kernel.org>; Tue, 27 Jun 2006 12:52:00 -0400 (EDT)
To: NetDev <netdev@vger.kernel.org>
In-Reply-To: <44A158EB.90406@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> No, that totally avoids my point.  Your "otherwise idle machine" test is
> probably nowhere near worst case in the field, for loops that can
> potentially lock the CPU for a long time upon hardware fault.  And then
> there are the huge delays in specific functions that I pointed out...
> 
>     Jeff

The problem is that these are the delays used in the original driver
that we've been writing the specs from.  We don't know what they're
for or why they're so long.  We don't know if reducing the delay
will cause issues on some hardware and work fine on others.  Without
the actual specs from Broadcom, it's hard to say what's excessive
and what's not and whether changing it will break the driver.

-Joe
