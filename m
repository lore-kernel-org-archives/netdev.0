From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2] ARM: net: JIT compiler for packet filters
Date: Thu, 22 Dec 2011 17:34:27 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AF25@saturn3.aculab.com>
References: <20111222170006.GA2321@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<linux@arm.linux.org.uk>
To: "Dave Martin" <dave.martin@linaro.org>,
	"Mircea Gherzan" <mgherzan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:57101 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752911Ab1LVRgC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2011 12:36:02 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 23466-04 for <netdev@vger.kernel.org>;
 Thu, 22 Dec 2011 17:35:57 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20111222170006.GA2321@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> In principle, the condition could be __LINUX_ARM_ARCH__ < 5, since the
> bx instruction is guaranteed to be available on all ARMv5 CPUs and
> later (ARMv5T is not required).

Can't this code look at the actual cpu being used, and
generate the relevant 'return' instruction?
(Instead of trying to use some compile-time value.)

	David
