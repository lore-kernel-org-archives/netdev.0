From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v4 net-next 11/12] bonding: trivial: rename
 slave->jiffies to ->last_link_up
Date: Mon, 17 Feb 2014 15:02:36 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6C18F7@AcuExch.aculab.com>
References: <1392648088-21336-1-git-send-email-vfalico@redhat.com>
 <1392648088-21336-12-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: 'Veaceslav Falico' <vfalico@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:33995 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752537AbaBQPDK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 10:03:10 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 07132-09 for <netdev@vger.kernel.org>;
 Mon, 17 Feb 2014 15:03:06 +0000 (GMT)
In-Reply-To: <1392648088-21336-12-git-send-email-vfalico@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -	unsigned long jiffies;
> +	/* all three in jiffies */
> +	unsigned long last_link_up;
>  	unsigned long last_arp_rx;
>  	unsigned long target_last_arp_rx[BOND_MAX_ARP_TARGETS];

Personally I'd add _time to the member names (maybe not the last
as that is long enough already).
I sometimes go as far as adding the time units (eg _ms or _sec)
just to avoid confusion when reading the code much later on.

	David
