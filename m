From: jamal <hadi@cyberus.ca>
Subject: Re: one more... iproute commands lockup whole system
Date: Tue, 03 Apr 2007 22:09:36 -0400
Message-ID: <1175652576.3957.43.camel@localhost>
References: <20070321175951.M73913@visp.net.lb> <46026717.9060909@trash.net>
	 <20070322124533.M79867@visp.net.lb> <46027FF2.6020001@trash.net>
	 <20070322101224.3e6bb899@freekitty>  <20070404000054.M58020@visp.net.lb>
	 <1175649016.3957.10.camel@localhost>  <461301C0.2050409@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Denys <denys@visp.net.lb>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.225]:3710 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966283AbXDDCJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2007 22:09:40 -0400
Received: by wx-out-0506.google.com with SMTP id h31so57156wxd
        for <netdev@vger.kernel.org>; Tue, 03 Apr 2007 19:09:39 -0700 (PDT)
In-Reply-To: <461301C0.2050409@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-04-04 at 03:39 +0200, Patrick McHardy wrote:

> Are you refering to "What NOT to do if you dont want your machine to
> crash:"? 

yes.

> I think we should make sure users can't even accidentally
> crash their box, so this should at least be caught at runtime.

It is hard to do without penalizing the common use. Hence
the documentation. 
Sometimes - that is the most sane thing to do. 

>I thought the TTL stuff was intended to avoid this ..

The problem is recursive dev queue locking of the same device.  
TTL is not very helpful there.

I dont want to rehash all those discussions we already had; so if you
have a clever way to fix this (without affecting performance of a sane
user), please send a patch and lets discuss.

cheers,
jamal

