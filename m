From: "Rami Rosen" <roszenrami@gmail.com>
Subject: Re: BUG: iwlwifi build failed
Date: Tue, 22 Jul 2008 10:42:53 +0300
Message-ID: <b25312890807220042i66fce3coe4947b569c335b5b@mail.gmail.com>
References: <d82e647a0807212143r2f598a59y76a79fd9bb8f17@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Ming Lei" <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:18612 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751769AbYGVHmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 03:42:54 -0400
Received: by wa-out-1112.google.com with SMTP id j37so1033032waf.23
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2008 00:42:54 -0700 (PDT)
In-Reply-To: <d82e647a0807212143r2f598a59y76a79fd9bb8f17@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
  - This problem was reported and a patch was sent recently; probably
it is not yet in your tree yet.

  - I assume that your .config file does not have CONFIG_IWLWIFI_DEBUG set.
On the net-2.6 current tree, when you **do** set the
CONFIG_IWLWIFI_DEBUG, this problem does not occur
(and, as can be understood, when CONFIG_IWLWIFI_DEBUG
is not set, it does occur).

So, if it is possible for you for the time being, till this patch
finds its way into the tree, I suggest that you
might set the CONFIG_IWLWIFI_DEBUG and run make.

More details on this patch you can find here:
http://linux.derkeiler.com/Mailing-Lists/Kernel/2008-07/msg09132.html

Regards,
Rami Rosen


On Tue, Jul 22, 2008 at 7:43 AM, Ming Lei <tom.leiming@gmail.com> wrote:
> commit 93ded9b8fd42abe2c3607097963d8de6ad9117eb
> Merge: 6d52dcb... f756cbd...
> Author: Linus Torvalds <torvalds@linux-foundation.org>
> Date:   Mon Jul 21 15:42:20 2008 -0700
> =====================================
>
> drivers/net/wireless/iwlwifi/iwl-led.c: In function 'iwl_led_brightness_set':
> drivers/net/wireless/iwlwifi/iwl-led.c:198: error: 'led_type_str'
> undeclared (first use in this function)
> drivers/net/wireless/iwlwifi/iwl-led.c:198: error: (Each undeclared
> identifier is reported only once
> drivers/net/wireless/iwlwifi/iwl-led.c:198: error: for each function
> it appears in.)
> make[4]: *** [drivers/net/wireless/iwlwifi/iwl-led.o] Error 1
> make[3]: *** [drivers/net/wireless/iwlwifi] Error 2
> make[2]: *** [drivers/net/wireless] Error 2
> make[1]: *** [drivers/net] Error 2
> make: *** [drivers] Error 2
>
>
> --
> Lei Ming
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
