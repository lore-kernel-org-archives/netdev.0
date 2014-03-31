From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/5] bonding: Initialize the ALB work queue for lb mode
 only.
Date: Mon, 31 Mar 2014 08:49:00 -0700
Message-ID: <1396280940.29410.38.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1396070946-17650-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:59329 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753454AbaCaPt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2014 11:49:26 -0400
Received: by mail-pd0-f176.google.com with SMTP id r10so8167332pdi.35
        for <netdev@vger.kernel.org>; Mon, 31 Mar 2014 08:49:25 -0700 (PDT)
In-Reply-To: <1396070946-17650-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-03-28 at 22:29 -0700, Mahesh Bandewar wrote:
> micro change to initialize / cancel the ALB work queue only
> if the mode selected is ALB or TLB.
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---

Can the mode of a bonding device be dynamically changed ?
