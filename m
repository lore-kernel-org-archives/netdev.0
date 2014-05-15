From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v5 2/2] net: systemport: pad packets to a
 minimum of 68 bytes
Date: Thu, 15 May 2014 09:28:13 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17246361@AcuExch.aculab.com>
References: <1400121134-6088-1-git-send-email-f.fainelli@gmail.com>
 <1400121134-6088-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>
To: 'Florian Fainelli' <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:59046 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750733AbaEOJ20 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 05:28:26 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 17720-01 for <netdev@vger.kernel.org>;
 Thu, 15 May 2014 10:28:16 +0100 (BST)
In-Reply-To: <1400121134-6088-3-git-send-email-f.fainelli@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli 
> With packets having Broadcom tags, the 4-bytes tag is first stripped
> off the packet, and the packet length is then checked, so we need to
> make sure that the packet length with FCS is at least 64 bytes.

Ah - finally an explanation!

I think you should only do that when the Broadcom Tags are enabled.

	David
