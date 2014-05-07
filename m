From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [Patch net-next] net: rename local_df to ignore_df
Date: Wed, 7 May 2014 13:49:09 -0700
Message-ID: <CAHo-OozOEZHDDWnt5AjjCjJ3o88s5z0Ez2i53R=6senGCLDFPA@mail.gmail.com>
References: <1399246758-29795-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140507.153014.491918803207368640.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux NetDev <netdev@vger.kernel.org>,
	Florian Westphal <fw@strlen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f41.google.com ([209.85.216.41]:62035 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644AbaEGUtK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 16:49:10 -0400
Received: by mail-qa0-f41.google.com with SMTP id dc16so1618968qab.14
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 13:49:09 -0700 (PDT)
In-Reply-To: <20140507.153014.491918803207368640.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've been wondering whether 'allow_frag' or 'allow_local_frag' or
'ignore_df_set' wouldn't be better names.

At some point we'll need to add a flag which does the opposite as well
(for locally generated tcp packets in non path mtu discovery mode),
'disallow_frag' or 'disallow_local_frag',  'force_df' or something
like that.  Picking two names which both are obvious and work well in
concert would be nice.
