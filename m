From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: TCP output handling bug ?
Date: Thu, 21 Aug 2014 17:24:45 -0700
Message-ID: <20140821172445.7c1ba422@uryu.home.lan>
References: <20140821190208.208e0de1@www.etchedpixels.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f175.google.com ([209.85.213.175]:45919 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751701AbaHVAYw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2014 20:24:52 -0400
Received: by mail-ig0-f175.google.com with SMTP id uq10so14177002igb.14
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2014 17:24:52 -0700 (PDT)
In-Reply-To: <20140821190208.208e0de1@www.etchedpixels.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Aug 2014 19:02:08 +0100
Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> 
> tcp_send_syn_data:
> 
>         TCP_SKB_CB(data)->tcp_flags &= ~TCPHDR_SYN;
>         TCP_SKB_CB(data)->tcp_flags = (TCPHDR_ACK|TCPHDR_PSH);
> 
> the reporter has a point 8)
> 
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=82101
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

I wonder if covertity or smatch could be smart enough to catch this kind of bug?
