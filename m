From: Vincent JARDIN <vincent.jardin@6wind.com>
Subject: Re: [PATCH net-next 0/3] openvswitch: Add STT support.
Date: Thu, 22 Jan 2015 00:46:31 +0100
Message-ID: <54C03A57.4080002@6wind.com>
References: <1421785536-19793-1-git-send-email-pshelar@nicira.com> <CA+mtBx90TipY9uJvW2uQfrCYL9JNM9Rk75HzdJPhE0qsdy8dnw@mail.gmail.com> <CALnjE+rSXpPftiG4Vw3azkN2s2-Ey6ZcZr9Bv422pOdwrvU=tw@mail.gmail.com> <CA+mtBx9yM+C8GeEHOGTHPVxNB3fJd7LQG0RaC3jywrO9_tQ58A@mail.gmail.com> <CALnjE+po5gy7g8ftmiNcnrN_gRL9tzCRHNtn=fxUafFikKB1rg@mail.gmail.com> <CA+mtBx-v5dvX-OPGeWJb6uwQGhJ5T6iewD83xJGqXb+Ggf+LQw@mail.gmail.com> <CAEP_g=-3GXJfawPb4jevkZhqmzTttsO1Rv_2J6GwpG=PR_a-0g@mail.gmail.com> <CA+mtBx9B5aS9Jv6tpUJpmBkvQFnUqjcxcgTjbBHee8K0f1C9KQ@mail.gmail.com> <CAEP_g=_B5xTcfONUP4PTw91PdJKx_cN_+Qdd4F6300aXVyzLZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pravin Shelar <pshelar@nicira.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>, Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:35149 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752462AbbAUXql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 18:46:41 -0500
Received: by mail-we0-f179.google.com with SMTP id q59so22463881wes.10
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2015 15:46:39 -0800 (PST)
In-Reply-To: <CAEP_g=_B5xTcfONUP4PTw91PdJKx_cN_+Qdd4F6300aXVyzLZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesse, Tom,

On 21/01/2015 23:14, Jesse Gross wrote:
>> I'm not going to try to draw conclusions from data which is obviously
>> >biased and incomplete. If you want to move forward on this, then just
>> >provide network interface for STT so we can independently run our own
>> >comparisons against other encapsulations like we've been doing all
>> >along.
> You have the source code, so you are totally free to run whatever
> tests you like to draw your own conclusions. Personally, I find a more
> than doubling of performance in the environments that I have seen
> compelling. Your mileage may vary.

+1 for STT in the kernel:
   - whatever the performances, it is needed because it happened to be 
used. If the patch can be optimized, someone will do and provide the 
related patches. The patch from Pravin is ok but...

   - ...I agree with Tom, a netdevice is a must have to ack't this 
patch. Such feature should not be added into openvswitch without its 
counter-part netdevice.

thank you,
   Vincent
