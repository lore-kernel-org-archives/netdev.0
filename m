From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] route: allow to route in a peer netns via lwt
 framework
Date: Fri, 24 Jul 2015 06:50:09 -0700
Message-ID: <55B24291.1040704@cumulusnetworks.com>
References: <1437661349-17620-1-git-send-email-nicolas.dichtel@6wind.com> <55B101DC.6040609@cumulusnetworks.com> <55B1077F.1090501@6wind.com> <55B10D50.9010704@cumulusnetworks.com> <55B22E64.2010405@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, tgraf@suug.ch
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34563 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752552AbbGXNuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 09:50:13 -0400
Received: by pacan13 with SMTP id an13so15126573pac.1
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 06:50:12 -0700 (PDT)
In-Reply-To: <55B22E64.2010405@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/24/15, 5:24 AM, Nicolas Dichtel wrote:
> Sure, but my goal was to not create a new .h file just for these two 
> helpers.
> It's related to lwtunnel, thus I was thinking they can go here.
ok..., since your lwt namespace functions went into net_namespace.c, I 
was thinking
these should really go into net_namespace.h. Does that work for you ?
If that does not, then yes, they could live here.

Thanks,
Roopa
