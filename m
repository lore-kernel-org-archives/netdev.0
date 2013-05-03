From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip: ipv6: add tokenized interface identifier
 support
Date: Fri, 3 May 2013 13:21:57 -0700
Message-ID: <20130503132157.06e6aca7@nehalam.linuxnetplumber.net>
References: <1367338970-2168-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:38734 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763500Ab3ECUWO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 16:22:14 -0400
Received: by mail-pd0-f170.google.com with SMTP id 10so1090242pdi.29
        for <netdev@vger.kernel.org>; Fri, 03 May 2013 13:22:13 -0700 (PDT)
In-Reply-To: <1367338970-2168-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Apr 2013 18:22:50 +0200
Daniel Borkmann <dborkman@redhat.com> wrote:

> This patch adds support for tokenized IIDs, that enable
> administrators to assign well-known host-part addresses
> to nodes whilst still obtaining global network prefix
> from Router Advertisements. This is the iproute2 part for
> the kernel patch f53adae4eae5 (``net: ipv6: add tokenized
> interface identifier support'').
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
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied
