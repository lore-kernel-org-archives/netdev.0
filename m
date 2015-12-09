From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Wed, 9 Dec 2015 23:25:44 +0100
Message-ID: <20151209222544.GF11201@pox.localdomain>
References: <20151209125857.GA9900@pox.localdomain>
 <20151209173842.GA18097@ast-mbp.thefacebook.com>
 <20151209220339.GD11201@pox.localdomain>
 <20151209.172128.2004885848439372720.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexei.starovoitov@gmail.com, jhs@mojatatu.com,
	john.fastabend@gmail.com, tom@herbertland.com,
	hannes@stressinduktion.org, linville@tuxdriver.com,
	jesse@kernel.org, anjali.singhai@intel.com, netdev@vger.kernel.org,
	kiran.patil@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:33774 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752788AbbLIWZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 17:25:46 -0500
Received: by mail-wm0-f41.google.com with SMTP id c201so6589999wme.0
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 14:25:46 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20151209.172128.2004885848439372720.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/09/15 at 05:21pm, David Miller wrote:
> It is clearly the most appropriate middle layer representation.
> 
> The fact that BPF could be generated from any P4 program, yet the
> reverse is not true, tells me everything I need to know.
> 
> I'm sorry if you have either a mental or a time invenstment in P4, but
> I really don't see it as really suitable for this.

I don't. I like the approach and the effect it has on a currently
very vendor secrets oriented environment.

I won't drag this further. I'm perfectly fine if BPF is suitable for
a wide range of hardware models.
