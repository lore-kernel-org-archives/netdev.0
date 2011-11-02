From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Bridge] [PATCH] bridge: Reset IPCB on forward non-local
 packets in br_handle_frame_finish()
Date: Wed, 2 Nov 2011 13:14:45 -0700
Message-ID: <20111102131445.28a92335@nehalam.linuxnetplumber.net>
References: <4EB19549.4010601@parallels.com>
	<20111102123106.107f4cb8@nehalam.linuxnetplumber.net>
	<CAPDOV48k=0c1anx7DC57u0x84tUVsFDQNO6=MiT+9eEE=Egi2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Vasily Averin <vvs@parallels.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>, devel@openvz.org,
	Herbert Xu <herbert@gondor.hengli.com.au>
To: Daniel Robbins <drobbins@funtoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36865 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750967Ab1KBUOs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Nov 2011 16:14:48 -0400
In-Reply-To: <CAPDOV48k=0c1anx7DC57u0x84tUVsFDQNO6=MiT+9eEE=Egi2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2 Nov 2011 13:45:29 -0600
Daniel Robbins <drobbins@funtoo.org> wrote:

> On Wed, Nov 2, 2011 at 1:31 PM, Stephen Hemminger <shemminger@vyatta.com> wrote:
> >
> > What kernel version are you using? There were several previous fixes
> > in br_netfilter to deal with this type of issue over the last year.
> 
> It's a kernel from this obscure company called Red Hat, and they
> include it in this product called Red Hat Enterprise Linux 6.
> 
> Specifically, 042stab37.1 :)
> 
> -Daniel

The pay for their tech support and have them fix it.
BTW - the problem was fixed upstream a long time ago, the upstream
kernel moves fast and RHEL probably froze many months before their
release.
