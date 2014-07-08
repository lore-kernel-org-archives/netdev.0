From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] return the right retcode when add a unreachable route
Date: Tue, 8 Jul 2014 11:49:02 -0700
Message-ID: <CAHA+R7OgTOCASmT03H37KKobb6m0hs3amF7GNWLy=JRLW+2dew@mail.gmail.com>
References: <1404644511-22112-1-git-send-email-lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:46385 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754838AbaGHStE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 14:49:04 -0400
Received: by mail-lb0-f179.google.com with SMTP id z11so4201015lbi.24
        for <netdev@vger.kernel.org>; Tue, 08 Jul 2014 11:49:02 -0700 (PDT)
In-Reply-To: <1404644511-22112-1-git-send-email-lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 6, 2014 at 4:01 AM, Xin Long <lucien.xin@gmail.com> wrote:
> when add a route like this:
> ip route add 74.125.31.199 dev eth0 via 1.2.3.4 ,
> 1.2.3.4 is a unreachable ip, it return -ENETUNREACH, it is ok.
> but before that I add a rule:
> ip rule add fwmark 1 lookup 101 ,
> then add that route , it will return -ESRCH.
>

This would potentially break user-space applications.
