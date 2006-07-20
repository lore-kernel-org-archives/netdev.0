From: Nicolas DICHTEL <nicolas.dichtel@6wind.com>
Subject: Re: Oops in IFB
Date: Thu, 20 Jul 2006 16:31:16 +0200
Message-ID: <44BF93B4.3030204@6wind.com>
References: <44BF8628.9080204@6wind.com>  <1153402801.5098.66.camel@jzny2> <1153403893.5098.79.camel@jzny2> <44BF934F.8050708@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080009030207020008050105"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail01.net-streams.fr ([62.23.133.110]:5642 "EHLO
	net-streams.fr") by vger.kernel.org with ESMTP id S932575AbWGTO2H
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jul 2006 10:28:07 -0400
To: hadi@cyberus.ca
In-Reply-To: <44BF934F.8050708@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080009030207020008050105
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

Sorry, I forgot the patch ;-)

Nicolas

Nicolas DICHTEL a écrit :
> jamal a écrit :
>> BTW, in the name of the LinuxWay(tm) - can you also submit a similar
>> patch for dummy? It suffers from the same bug.
> No problem, patch is enclosed.
>
> Cheers,
> Nicolas
>
> [DUMMY] Avoid an oops when dummy_init_one() failed
>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

--------------080009030207020008050105
Content-Type: text/x-patch;
 name="x.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x.diff"

--- a/drivers/net/dummy.c	2006-07-20 16:19:09.395351558 +0200
+++ b/drivers/net/dummy.c	2006-07-20 16:19:58.802327279 +0200
@@ -132,6 +132,7 @@
 	for (i = 0; i < numdummies && !err; i++)
 		err = dummy_init_one(i); 
 	if (err) { 
+		i--;
 		while (--i >= 0)
 			dummy_free_one(i);
 	}

--------------080009030207020008050105--
