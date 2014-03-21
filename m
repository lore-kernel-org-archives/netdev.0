From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] iproute: Show default type, table, proto and scope of
 route
Date: Fri, 21 Mar 2014 14:22:38 -0700
Message-ID: <20140321142238.0a81d1e3@nehalam.linuxnetplumber.net>
References: <1394596013-25090-1-git-send-email-yamato@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Masatake YAMATO <yamato@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:59981 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085AbaCUVWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2014 17:22:41 -0400
Received: by mail-pd0-f182.google.com with SMTP id y10so2820635pdj.41
        for <netdev@vger.kernel.org>; Fri, 21 Mar 2014 14:22:41 -0700 (PDT)
In-Reply-To: <1394596013-25090-1-git-send-email-yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 12 Mar 2014 12:46:53 +0900
Masatake YAMATO <yamato@redhat.com> wrote:

> In "ip route show" output unicast type, main table, boot protocol and
> universe scope are hidden as default labels.
> 
> Sometimes it is helpful to show the hidden label for people not enough
> familiar with routing subsystem to map the output of "ip route show" and
> kernel source code.
> 
> With this patch "ip route show" with -d option shows the default labels.
> 
> Example of difference of output with -d option:
> 
>     $ ./ip/ip -4   route show table all dev virbr1
>     ...
>     192.168.121.0/28  proto kernel  scope link  src 192.168.121.1
>     ...
>     $ ./ip/ip -4 -d  route show table all dev virbr1
>     ...
>     unicast 192.168.121.0/28  table main  proto kernel  scope link  src 192.168.121.1
>     ...
> 
> Signed-off-by: Masatake YAMATO <yamato@redhat.com>

Looks good, applied
