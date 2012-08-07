From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/5 (resend)] net: Allow to create links with given
 ifindex
Date: Tue, 07 Aug 2012 15:14:26 +0200
Message-ID: <1344345266.28967.91.camel@edumazet-glaptop>
References: <501FD0F2.4040609@parallels.com>
	 <501FD13E.1030404@parallels.com>  <5020F58C.8070605@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:58223 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753661Ab2HGNOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 09:14:30 -0400
Received: by mail-bk0-f46.google.com with SMTP id j10so1439595bkw.19
        for <netdev@vger.kernel.org>; Tue, 07 Aug 2012 06:14:30 -0700 (PDT)
In-Reply-To: <5020F58C.8070605@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-08-07 at 15:01 +0400, Pavel Emelyanov wrote:
> Currently the RTM_NEWLINK results in -EOPNOTSUPP if the ifinfomsg->ifi_index
> is not zero. I propose to allow requesting ifindices on link creation. This
> is required by the checkpoint-restore to correctly restore a net namespace
> (i.e. -- a container).
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

Acked-by: Eric Dumazet <edumazet@google.com>
