From: "Parag Warudkar" <parag.warudkar@gmail.com>
Subject: Re: Unexpected Acknowledgement / Stalled Connections
Date: Sun, 4 Feb 2007 17:56:55 -0500
Message-ID: <82e4877d0702041456u5d30d32bs41233048a1833d59@mail.gmail.com>
References: <82e4877d0702041431p555e644et35845db674304403@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.234]:57440 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593AbXBDW44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Feb 2007 17:56:56 -0500
Received: by wx-out-0506.google.com with SMTP id h31so1445247wxd
        for <netdev@vger.kernel.org>; Sun, 04 Feb 2007 14:56:56 -0800 (PST)
In-Reply-To: <82e4877d0702041431p555e644et35845db674304403@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/4/07, Parag Warudkar <parag.warudkar@gmail.com> wrote:
> I am running 2.6.20 and have trouble with stalled connections. For
> instance, if I try to download a debian ISO image using wget, the
> connection runs fine for few seconds and then stalls for ever.
>
> In my router logs I see a ton of messages like the below -
>
> [INFO] Sun Feb 04 17:22:03 2007 Blocked incoming TCP packet from
> 192.168.0.174:34090 to 130.239.18.138:80 with unexpected
> acknowledgement 3269301836 (expected 3269343453 to 3269408989)
>
> Where 192.168.0.174 is my laptop running FC6 and kernel 2.6.20 and
> 130.239.18.138 is whatever cdimage.debian.org resolves to atm.
>
> What's going on here? Any TCP/IP tunable that I can set/turn on/off to
> prevent this from happening?

Turning tcp_sack off seems to cure it. Turning it on again makes the
connections stall. Seems like the D-Link router doesn't like the SACKs
linux sends?

Parag
