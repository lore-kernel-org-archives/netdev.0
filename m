From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 4/4] net/mlx4_en: get rid of private net_device_stats
Date: Thu, 26 May 2016 05:59:40 -0700
Message-ID: <1464267580.5939.83.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1464195039-5098-1-git-send-email-edumazet@google.com>
	 <1464195039-5098-5-git-send-email-edumazet@google.com>
	 <6320ccdc-d369-c08c-c959-6c8ed9b88d10@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35259 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753380AbcEZM7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 08:59:42 -0400
Received: by mail-pa0-f66.google.com with SMTP id gp3so2226346pac.2
        for <netdev@vger.kernel.org>; Thu, 26 May 2016 05:59:42 -0700 (PDT)
In-Reply-To: <6320ccdc-d369-c08c-c959-6c8ed9b88d10@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-05-26 at 12:38 +0300, Tariq Toukan wrote:
> Hi Eric,
> 
> Thanks for the fix.
> 
> > We do not need to clear fields that are already 0.
> Why is it always true that dev->stats is already 0 at the point ndo_open 
> is called?

netdev structs are zero allocated. (kzalloc)
