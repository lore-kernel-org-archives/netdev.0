From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH iproute2] libnetlink: check flag NLM_F_DUMP_INTR during
 dumps
Date: Fri, 22 Mar 2013 07:59:53 -0700
Message-ID: <1363964393.4431.66.camel@edumazet-glaptop>
References: <1363963557-3888-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:34259 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933584Ab3CVO7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 10:59:55 -0400
Received: by mail-pd0-f177.google.com with SMTP id y14so1614857pdi.8
        for <netdev@vger.kernel.org>; Fri, 22 Mar 2013 07:59:55 -0700 (PDT)
In-Reply-To: <1363963557-3888-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-22 at 15:45 +0100, Nicolas Dichtel wrote:
> When this flag is set, it means that dump was interrupted and result may be
> wrong. Ask user to restart.
> 
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>


Do we have a guarantee this will complete eventually, on some hosts
constantly adding removing entries ?
