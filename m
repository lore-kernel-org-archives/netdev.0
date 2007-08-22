From: Bruce Cole <bacole@gmail.com>
Subject: r8169: slow samba performance
Date: Wed, 22 Aug 2007 09:39:47 -0700
Message-ID: <46CC66D3.8030602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bacole@gmail.com
To: shane@cm.nu
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.229]:63718 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759291AbXHVQlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 12:41:49 -0400
Received: by qb-out-0506.google.com with SMTP id e11so1243508qbe
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 09:41:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>Just upgraded a motherboard and it came with an onboard
>Realtek card which appears to use the r8169 driver.  The
>machine is a samba server and when serving files to a local
>Linux or Windows client, I only get approx 40-60 kbps. 
>Write performance is fine though, in the tens of mbps and
>scp, nfs, and ftp server all work well so it appears
>specific to the Samba load.  However, when serving to more
>than one client symoltaniously, performance goes up
>dramatically, again into the tens of mbps or when there is
>other network activity.

Shane, join the crowd :)  Try the fix I just re-posted over here:

http://www.spinics.net/lists/netdev/msg39244.html



