From: Vincent JARDIN <vincent.jardin@6wind.com>
Subject: Re: [PATCH net-next 0/3] openvswitch: Add STT support.
Date: Thu, 22 Jan 2015 18:51:55 +0100
Message-ID: <54C138BB.7000407@6wind.com>
References: <1421785536-19793-1-git-send-email-pshelar@nicira.com>	<CA+mtBx90TipY9uJvW2uQfrCYL9JNM9Rk75HzdJPhE0qsdy8dnw@mail.gmail.com>	<CALnjE+rSXpPftiG4Vw3azkN2s2-Ey6ZcZr9Bv422pOdwrvU=tw@mail.gmail.com>	<CA+mtBx9yM+C8GeEHOGTHPVxNB3fJd7LQG0RaC3jywrO9_tQ58A@mail.gmail.com>	<CALnjE+po5gy7g8ftmiNcnrN_gRL9tzCRHNtn=fxUafFikKB1rg@mail.gmail.com>	<CA+mtBx-v5dvX-OPGeWJb6uwQGhJ5T6iewD83xJGqXb+Ggf+LQw@mail.gmail.com>	<CAEP_g=-3GXJfawPb4jevkZhqmzTttsO1Rv_2J6GwpG=PR_a-0g@mail.gmail.com>	<CA+mtBx9B5aS9Jv6tpUJpmBkvQFnUqjcxcgTjbBHee8K0f1C9KQ@mail.gmail.com>	<CAEP_g=_B5xTcfONUP4PTw91PdJKx_cN_+Qdd4F6300aXVyzLZg@mail.gmail.com>	<54C03A57.4080002@6wind.com> <CA+mtBx9pnkJBVftqFTK6fcd-toAxsJrvB=drTxWQs_=5s9C0+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesse Gross <jesse@nicira.com>, Pravin Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:39770 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752135AbbAVRv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 12:51:58 -0500
Received: by mail-wg0-f49.google.com with SMTP id l18so3160284wgh.8
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 09:51:57 -0800 (PST)
In-Reply-To: <CA+mtBx9pnkJBVftqFTK6fcd-toAxsJrvB=drTxWQs_=5s9C0+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/01/2015 17:24, Tom Herbert wrote:
> STT is undoubtedly a creative and unique solution I'll give you that,
> but the potential repercussions of allowing this to be widely deployed
> are profound. IMO this needs to be fully explored before it can ever
> be allowed in the kernel. If there has already been discussion on this
> please forward a pointer (I didn't find anything in the IETF mailing
> list archives other than the draft posting announcements), but at the
> minimum these patches warrant a lot of scrutiny.

I share this concern of biased use of TCP, all the critics will be 
valid. But anyone can hack TCP (so peer to peer software does or CDN 
software does). So, I prefer the let the freedom to the sysadmin to 
enable/disable it for their networks. Not having this feature into the 
kernel prevent sysadmin from doing it. To be safe, it can be an 
experimental feature of the Linux kernel.

Same: LRO/GRO is is bad features: it breaks many times networking (most 
IP forwarders must disable it), but it helps for servers. Same for STT 
in fact, it has its narrow set of use-cases which are valid.

Best regards,
   Vincent
