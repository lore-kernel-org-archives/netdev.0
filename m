From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Information about SCTP patch
Date: Thu, 26 Jun 2014 00:47:53 -0700
Message-ID: <1403768873.374.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAJ5TDg_0GjTWVin1Xr4sZwNhzMiT+bJPZwzfKB0xBdPMuK7T+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: kishan simha <ksimha123@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:58250 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754709AbaFZHr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 03:47:57 -0400
In-Reply-To: <CAJ5TDg_0GjTWVin1Xr4sZwNhzMiT+bJPZwzfKB0xBdPMuK7T+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-06-26 at 12:58 +0530, kishan simha wrote:
> Hello,
> 
> I wanted some information on the SCTP patch   "sctp: Add support to
> per-association statistics via a new SCTP_GET_ASSOC_STA "
> 
> 
> The commit information is
> 
> commit 196d67593439b03088913227093e374235596e33
> 
> Author: Michele Baldessari <michele@acksyn.org>
> 
> Date:   Sat Dec 1 04:49:42 2012 +0000
> 
> 
> Is it possible to know into which kernel version did this patch go into?
> I tried to find it online and I was not able to. Hence mailing to this list.
> 
> It will be helpful if you anyone answer this.

Sure :

$ git describe --contains 196d67593439b03088913227093e374235596e33

v3.8-rc1~139^2~117


So all linux versions starting from linux-3.8 have it.
