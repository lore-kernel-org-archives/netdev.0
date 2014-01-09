From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH v2 3/4] net: make tcp_cleanup_rbuf private
Date: Thu, 9 Jan 2014 15:26:17 -0500
Message-ID: <CADVnQy=Tk68y217cbw7O5apCJV+eOmKMqLNbgAZRa_cxUArdKg@mail.gmail.com>
References: <20140109201157.28381.94057.stgit@viggo.jf.intel.com>
	<20140109201642.28381.82141.stgit@viggo.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: dmaengine@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Netdev <netdev@vger.kernel.org>,
	James Morris <jmorris@namei.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	Patrick McHardy <kaber@trash.net>,
	LKML <linux-kernel@vger.kernel.org>
To: Dan Williams <dan.j.williams@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:36965 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756695AbaAIU0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 15:26:18 -0500
Received: by mail-ea0-f178.google.com with SMTP id d10so1739745eaj.9
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 12:26:17 -0800 (PST)
In-Reply-To: <20140109201642.28381.82141.stgit@viggo.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 9, 2014 at 3:16 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> net_dma was the only external user so this can become local to tcp.c
> again.
...
> -void tcp_cleanup_rbuf(struct sock *sk, int copied)
> +static void cleanup_rbuf(struct sock *sk, int copied)

I would vote to keep the tcp_ prefix. In the TCP code base that is the
more common idiom, even for internal/static TCP functions, and
personally I find it easier to read and work with in stack traces,
etc. My 2 cents.

neal
