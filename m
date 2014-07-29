From: Cong Wang <cwang@twopensource.com>
Subject: Re: Port attributes configuration
Date: Tue, 29 Jul 2014 10:53:15 -0700
Message-ID: <CAHA+R7N_X5GuXG-MyRcpHcbzKDLh9kDKr52G7hqT=RwMjrTA1A@mail.gmail.com>
References: <CACWm-Bc4=4We1AfnZpL7O5VkUSKjKBZ-NK6edXW2fE5b_u-e7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Marco Varlese <marco.varlese@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:36628 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751205AbaG2RxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2014 13:53:16 -0400
Received: by mail-la0-f44.google.com with SMTP id e16so11231lan.3
        for <netdev@vger.kernel.org>; Tue, 29 Jul 2014 10:53:15 -0700 (PDT)
In-Reply-To: <CACWm-Bc4=4We1AfnZpL7O5VkUSKjKBZ-NK6edXW2fE5b_u-e7g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 29, 2014 at 2:15 AM, Marco Varlese <marco.varlese@gmail.com> wrote:
> I'm working on a new platform and the network interfaces will have
> quite few new options (roughly 50) to configure. What I definitely
> want to achieve is to use the common tools available on Linux to let
> users configure the port attributes from user-space without writing a
> brand new ad-hoc tool.
>

Netlink is definitely preferred unless you have a reason not to use it.
You don't give any details so I can't tell much.

You probably don't have to write a new tool from scratch, i.e. parsing
netlink attributes all by yourself, you probably can just patch existing
iproute2.
