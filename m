From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH] [REVISED] net/ipv4/multipath_wrandom.c: check kmalloc() return value.
Date: Mon, 12 Mar 2007 14:36:46 +0200
Message-ID: <84144f020703120536l3967dc76o6a130edc79762350@mail.gmail.com>
References: <20070308.232908.92582631.davem@davemloft.net>
	 <20070312115137.GA3270@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, amit2030@gmail.com,
	linux-kernel@vger.kernel.org, akpm@osdl.org, netdev@vger.kernel.org
To: "Jarek Poplawski" <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:4222 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965789AbXCLMgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 08:36:49 -0400
Received: by nf-out-0910.google.com with SMTP id o25so1996951nfa
        for <netdev@vger.kernel.org>; Mon, 12 Mar 2007 05:36:47 -0700 (PDT)
In-Reply-To: <20070312115137.GA3270@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/12/07, Jarek Poplawski <jarkao2@o2.pl> wrote:
> So, maybe it's less evil to check those NULLs where possible and add
> some WARN_ONs here and there...

No, it's much better to oops rather than paper over a bug.
