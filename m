From: <Bryan.Whitehead@microchip.com>
Subject: RE: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Fri, 19 Feb 2016 19:29:46 +0000
Message-ID: <90A7E81AE28BAE4CBDDB3B35F187D264402F0018@CHN-SV-EXMX02.mchp-main.com>
References: <20160216203625.GC2558@lunn.ch>
 <20160216.154358.164326104187806534.davem@davemloft.net>
 <90A7E81AE28BAE4CBDDB3B35F187D264402EFB5D@CHN-SV-EXMX02.mchp-main.com>
 <20160216.155244.2052910262411568012.davem@davemloft.net>
 <90A7E81AE28BAE4CBDDB3B35F187D264402EFB82@CHN-SV-EXMX02.mchp-main.com>
 <20160216221536.GB6033@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <f.fainelli@gmail.com>,
	<netdev@vger.kernel.org>
To: <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:20190 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S2993202AbcBST3s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 14:29:48 -0500
In-Reply-To: <20160216221536.GB6033@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Tuesday, February 16, 2016 5:16 PM
> 
> You are already 1/2 way to a DSA driver, since you have a MAC driver. So i
> agree with David, do it right and add a simple DSA driver.
> 
Andrew,

I've done a little research on DSA.
I've read Documentation/networking/dsa/dsa.txt
And I've looked over some examples in drivers/net/dsa/

It appears there are about 40 functions to implement.
I see examples from only 2 manufacturers, and they average more than 2000 lines of code.
I'm not yet sure how it attaches to the underlying Ethernet driver.
And I have no idea how I would test it at the end. 

Given these issues, it will be hard to sell it to my manager.
Since you claim it is simple. Can you explain your reasons?

I've never done a DSA driver before. Given that, can you generally outline the steps.
If it can be partly implemented, which parts should be implemented first?

I appreciate any pointers you can provide.

Bryan
