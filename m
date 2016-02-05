From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 6/7] soreuseport: fast reuseport TCP socket
 selection
Date: Thu, 04 Feb 2016 21:38:26 -0800
Message-ID: <1454650706.7627.303.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1454600118-30152-1-git-send-email-kraigatgoog@gmail.com>
	 <1454600118-30152-7-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35159 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751247AbcBEFi2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 00:38:28 -0500
Received: by mail-pf0-f178.google.com with SMTP id 65so62876043pfd.2
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 21:38:27 -0800 (PST)
In-Reply-To: <1454600118-30152-7-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-02-04 at 10:35 -0500, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
> 
> This change extends the fast SO_REUSEPORT socket lookup implemented
> for UDP to TCP.  Listener sockets with SO_REUSEPORT and the same
> receive address are additionally added to an array for faster
> random access.  This means that only a single socket from the group
> must be found in the listener list before any socket in the group can
> be used to receive a packet.  Previously, every socket in the group
> needed to be considered before handing off the incoming packet.

Acked-by: Eric Dumazet <edumazet@google.com>
