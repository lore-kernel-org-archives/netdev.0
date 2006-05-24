From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1] connector: export cn_already_initialized.
Date: Wed, 24 May 2006 12:38:21 +0400
Message-ID: <20060524083821.GA12540@2ka.mipt.ru>
References: <20060504122421.GA8576@2ka.mipt.ru> <20060505.171646.65488074.davem@davemloft.net> <20060506084045.GA16558@2ka.mipt.ru> <20060516.161406.23276754.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:42187 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932667AbWEXIiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 04:38:16 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060516.161406.23276754.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 16, 2006 at 04:14:06PM -0700, David S. Miller (davem@davemloft.net) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Sat, 6 May 2006 12:40:45 +0400
> > I think the right solution is to call external init functions after cn
> > init function, but it's ordering is not always known.
> 
> In-kernel build of connector subsystem can be handled by
> making cn_init a "subsystem_init()", it will then be setup
> before any possible static or modular reference as long as
> those modules use module_init().

subsystem_init() seems to be kobject related initilizator.
Maybe subsys_initcall()?

I will cook up a patch if it works.
Thank you.

-- 
	Evgeniy Polyakov
