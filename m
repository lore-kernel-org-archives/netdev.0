From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next 0/3] L3 RX handler
Date: Fri, 28 Aug 2015 18:31:07 -0700
Message-ID: <1440811867.8932.111.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1440808463-14526-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35119 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565AbbH2BbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 21:31:09 -0400
Received: by pacdd16 with SMTP id dd16so78808392pac.2
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 18:31:09 -0700 (PDT)
In-Reply-To: <1440808463-14526-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-08-28 at 17:34 -0700, David Ahern wrote:
> Currently the VRF driver registers an Rx handler for enslaved devices.
> The handler switches the skb->dev to the VRF device and sends it back for
> another pass. While this works fine a side effect is that it bypasses
> netfilter with the skb set to the original device.
> 

Arg ... yet another hook in packet processing fast path...

What are long term plans for VRF ? Will it stay VRF-Lite or what ?
