From: Lance Richardson <lrichard@redhat.com>
Subject: Re: [PATCH net] vxlan: eliminate cached dst leak
Date: Thu, 1 Jun 2017 15:07:08 -0400 (EDT)
Message-ID: <748426696.17969649.1496344028160.JavaMail.zimbra@redhat.com>
References: <20170529172557.7065-1-lrichard@redhat.com> <20170601.144648.1946518537495893731.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, pabeni@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44658 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751083AbdFATHJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 15:07:09 -0400
In-Reply-To: <20170601.144648.1946518537495893731.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: "David Miller" <davem@davemloft.net>
> To: lrichard@redhat.com
> Cc: netdev@vger.kernel.org, pabeni@redhat.com
> Sent: Thursday, 1 June, 2017 2:46:48 PM
> Subject: Re: [PATCH net] vxlan: eliminate cached dst leak
> 
> From: Lance Richardson <lrichard@redhat.com>
> Date: Mon, 29 May 2017 13:25:57 -0400
> 
> > After commit 0c1d70af924b ("net: use dst_cache for vxlan device"),
> > cached dst entries could be leaked when more than one remote was
> > present for a given vxlan_fdb entry, causing subsequent netns
> > operations to block indefinitely and "unregister_netdevice: waiting
> > for lo to become free." messages to appear in the kernel log.
> > 
> > Fix by properly releasing cached dst and freeing resources in this
> > case.
> > 
> > Fixes: commit 0c1d70af924b ("net: use dst_cache for vxlan device")
> 
> In the future please do not put that "commit " string there, it's not
> needed.

Oops, sorry about that, I know I've made that mistake before (both times
because a checkpatch.pl warning in the body made me think I needed to
change the Fixes: tag as well).  Now I'm tempted to roll a checkpatch.pl
improvement...

> 
> > Signed-off-by: Lance Richardson <lrichard@redhat.com>
> 
> Applied and queued up for -stable, thank you.
> 
