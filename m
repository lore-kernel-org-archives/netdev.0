From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2.6.21.3] bonding: Fix 802.3ad no carrier on "no partner
 found" instance
Date: Sat, 09 Jun 2007 18:25:29 -0400
Message-ID: <466B28D9.6040806@garzik.org>
References: <97949e3e0706011316n5d90bb04kf3a2c556af3fbe9d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Laurent Chavey <chavey@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35130 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752134AbXFIWZb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jun 2007 18:25:31 -0400
In-Reply-To: <97949e3e0706011316n5d90bb04kf3a2c556af3fbe9d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Laurent Chavey wrote:
> Remove the requirement to have at least one configured partner to
> enable the operation of links. The later is necessary to have the code
> in compliance with section 43.3.9 of IEEE 802.3,
> 
> Signed-off-by: Laurent Chavey <chavey@google.com>

Looks OK but patch is corrupted:

[jgarzik@pretzel netdev-2.6]$ git-am --signoff --utf8 /g/tmp/mbox

Applying 'bonding: Fix 802.3ad no carrier on "no partner found" instance'

fatal: patch fragment without header at line 7: @@ -2303,19 +2303,17 @@
Patch failed at 0001.
When you have resolved this problem run "git-am --resolved".
If you would prefer to skip this patch, instead run "git-am --skip".

