From: ratheesh k <ratheesh.ksz@gmail.com>
Subject: printk mac address --hangs
Date: Thu, 13 May 2010 10:46:28 +0530
Message-ID: <AANLkTinyUkQXbwD1QNI4he5XR0EdUzMnpYKI6xd-vifP@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:55168 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751795Ab0EMFQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 01:16:29 -0400
Received: by pxi5 with SMTP id 5so486759pxi.19
        for <netdev@vger.kernel.org>; Wed, 12 May 2010 22:16:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

/* code snippent */
 char src[ETH_ALEN+2];
 char dst[ETH_ALEN+2];

 eth_header = eth_hdr(skb);
 memcpy(src , eth_header->h_source , ETH_ALEN );
 memcpy(dst , eth_header->h_dest , ETH_ALEN );


Linux crashes . But if comment out memcpy lines  . It works . What is
the problem here ?
How can i printk both source mac and dest mac address  ?

Thanks,
Ratheesh
