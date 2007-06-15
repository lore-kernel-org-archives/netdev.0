From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [Xen-devel] [PATCH 4/4] [Net] Support accelerated network
 plugin modules
Date: Fri, 15 Jun 2007 09:06:14 -0700
Message-ID: <20070615090614.19871370@localhost>
References: <1181904393.4121.55.camel@moonstone.uk.level5networks.com>
	<4e777ed10706150859r3b6e1617o3b31e5e24a30e6c9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Kieran Mansley" <kmansley@solarflare.com>,
	xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: "Zhu Han" <schumi.han@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:40254 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750894AbXFOQHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jun 2007 12:07:36 -0400
In-Reply-To: <4e777ed10706150859r3b6e1617o3b31e5e24a30e6c9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 15 Jun 2007 11:59:43 -0400
"Zhu Han" <schumi.han@gmail.com> wrote:

> Hi, Kieran,
> 
> I'm just wonder why you try to acquire the lock and increase the
> hooks_usecount each time when you use the hook routine. Is there any
> generic ways to synchronze the code path using hook routines and
> netfront_accelerator_unloaded, considering you can synchronize the
> 

Learn to use RCU for this. It would reduce the lock overhead.
