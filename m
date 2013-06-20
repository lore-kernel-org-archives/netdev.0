From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/2] netdev: octeon_mgmt: Fix structure layout for little-endian.
Date: Thu, 20 Jun 2013 10:47:57 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B729B@saturn3.aculab.com>
References: <1371688820-4585-1-git-send-email-ddaney.cavm@gmail.com> <1371688820-4585-3-git-send-email-ddaney.cavm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <linux-mips@linux-mips.org>, "David Daney" <david.daney@cavium.com>
To: "David Daney" <ddaney.cavm@gmail.com>, <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49037 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755057Ab3FTLfc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 07:35:32 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 23038-03 for <netdev@vger.kernel.org>;
 Thu, 20 Jun 2013 12:35:28 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1371688820-4585-3-git-send-email-ddaney.cavm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The C ABI reverses the bitfield fill order when compiled as
> little-endian.

No - it is completely implementation defined.
The general concensus is not to use bitfields if you
care at all about the bit assignments.

	David
