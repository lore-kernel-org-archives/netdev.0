From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2] man ip-netns: Notice about loose device when do
 'del'
Date: Sun, 15 Mar 2015 17:25:02 +0200
Message-ID: <20150315152502.GA7894@angus-think.lan>
References: <1426417044-6754-1-git-send-email-vadim4j@gmail.com>
 <5505A353.5090405@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vadim Kochan <vadim4j@gmail.com>, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f49.google.com ([209.85.215.49]:35138 "EHLO
	mail-la0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752115AbbCOPgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 11:36:41 -0400
Received: by labjg1 with SMTP id jg1so21878825lab.2
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 08:36:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <5505A353.5090405@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 15, 2015 at 06:20:51PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 3/15/2015 1:57 PM, Vadim Kochan wrote:
> 
> >From: Vadim Kochan <vadim4j@gmail.com>
> 
>    Noticed a few typos...
> 
> >Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> >---
> >  man/man8/ip-netns.8 | 25 ++++++++++++++++++++++---
> >  1 file changed, 22 insertions(+), 3 deletions(-)
> 
> >diff --git a/man/man8/ip-netns.8 b/man/man8/ip-netns.8
> >index 28a9544..062564d 100644
> >--- a/man/man8/ip-netns.8
> >+++ b/man/man8/ip-netns.8
> >@@ -46,6 +46,9 @@ ip-netns \- process network namespace management
> >  A network namespace is logically another copy of the network stack,
> >  with its own routes, firewall rules, and network devices.
> >
> >+By default process inherites network namespace from its parent. Initially all
> 
>    s/inherites/inherits/.
> 
> >+the processes shares the same default network namespace from the init process.
> 
>    s/shares/share/.
> 
> >+
> >  By convention a named network namespace is an object at
> >  .BR "/var/run/netns/" NAME
> >  that can be opened.  The file descriptor resulting from opening
> >@@ -88,14 +91,30 @@ network namespace and assigns NAME.
> >  .sp
> >  If NAME is present in /var/run/netns it is umounted and the mount
> >  point is removed.  If this is the last user of the network namespace the
> >-network namespace will be freed, otherwise the network namespace
> >-persists until it has no more users.  ip netns delete may fail if
> >-the mount point is in use in another mount namespace.
> >+network namespace will be freed and all physical devices will be moved to the
> >+default one, otherwise the network namespace persists until it has no more
> >+users. ip netns delete may fail if the mount point is in use in another mount
> >+namespace.
> >
> >  If
> >  .B -all
> >  option was specified then all the network namespace names will be removed.
> >
> >+It is possible to "loose" the physical device when it was moved to netns and
> 
>    Not "lose"?
> 
> >+then this netns was deleted with a running process:
> 
> [...]
> 
> WBR, Sergei
> 

Thank You!
