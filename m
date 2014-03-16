From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: What's the status of TCP friends?
Date: Sun, 16 Mar 2014 07:03:39 -0700
Message-ID: <1394978619.9668.14.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140316090744.GA14572@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Li Yu <bingtian.ly@taobao.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Bruce Brutus Curtis <brutus@google.com>,
	Weiping Pan <panweiping3@gmail.com>
To: Zheng Liu <gnehzuil.liu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:49951 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634AbaCPODl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Mar 2014 10:03:41 -0400
Received: by mail-pb0-f41.google.com with SMTP id jt11so4629482pbb.0
        for <netdev@vger.kernel.org>; Sun, 16 Mar 2014 07:03:41 -0700 (PDT)
In-Reply-To: <20140316090744.GA14572@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-03-16 at 17:07 +0800, Zheng Liu wrote:
> Hi all,
> 
> Until now the TCP friends patch set doesn't be applied.  Now what's the
> status of TCP friends?  Is it applicable to be merged into upstream
> kernel?  Any problem that needs to be fixed?  Please let me know if I
> can help.

Well, last attempts showed that while the idea sounded cool,
implementation opened many races and added quite a lot of complexity in
fast path.

We have AF_UNIX with a lot of problems in it, do we really want to bring
these AF_UNIX problems to AF_INET ?

I would rather spend time on AF_UNIX if it doesn't fit your needs right
now, or consider jumping to KDBUS modern design.

Using AF_INET for IPC is poor choice.
