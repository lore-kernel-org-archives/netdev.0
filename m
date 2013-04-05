From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 2/2] ip: ipv6: add tokenized interface
 identifier support
Date: Fri, 5 Apr 2013 09:39:14 -0700
Message-ID: <20130405093914.55c9114c@nehalam.linuxnetplumber.net>
References: <1365086258-4512-1-git-send-email-dborkman@redhat.com>
	<1365086258-4512-3-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:35640 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161970Ab3DEQjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 12:39:37 -0400
Received: by mail-pa0-f45.google.com with SMTP id kl13so2127174pab.18
        for <netdev@vger.kernel.org>; Fri, 05 Apr 2013 09:39:36 -0700 (PDT)
In-Reply-To: <1365086258-4512-3-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  4 Apr 2013 16:37:38 +0200
Daniel Borkmann <dborkman@redhat.com> wrote:

> This is experimental support for tokenized IIDs, that enable
> administrators to assign well-known host-part addresses to nodes
> whilst still obtaining global network prefix from Router
> Advertisements. It is currently in IETF RFC draft status [1].
> 
> Example commands with iproute2:
> 
> Setting a device token:
>   # ip token set ::1a:2b:3c:4d/64 dev eth1
> 
> Getting a device token:
>   # ip token get dev eth1
>   token ::1a:2b:3c:4d dev eth1
> 
> Listing all tokens:
>   # ip token list  (or: ip token)
>   token :: dev eth0
>   token ::1a:2b:3c:4d dev eth1
> 
>  [1] http://tools.ietf.org/html/draft-chown-6man-tokenised-ipv6-identifiers-02
> 
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Deferred.
Please resubmit during 3.10 merge window.
