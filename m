From: Grey Christoforo <grey@christoforo.net>
Subject: Re: 4.7-rc1 wifi driver bug report
Date: Thu, 2 Jun 2016 12:52:45 +0100
Message-ID: <CADbsYN1VaS55JJ9Kfw6_qQprMG=k_hAvVeXyDBio2AeUmx+n0A@mail.gmail.com>
References: <CADbsYN1w2DT58fwuGcqSK91Dz_-GMxX5H6boULN2WZ0fbPs50w@mail.gmail.com>
 <0c511fa2-8ad5-7f12-65d8-646ad87ae65c@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Arend Van Spriel <arend.vanspriel@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36041 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932659AbcFBLxH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 07:53:07 -0400
Received: by mail-wm0-f49.google.com with SMTP id n184so75966208wmn.1
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2016 04:53:05 -0700 (PDT)
In-Reply-To: <0c511fa2-8ad5-7f12-65d8-646ad87ae65c@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 1, 2016 at 10:22 PM, Arend Van Spriel
<arend.vanspriel@broadcom.com> wrote:
> On 31-5-2016 13:46, Grey Christoforo wrote:
>> Hi,
>>
>> I found the following in my dmesg today when I tried out 4.7-rc1 on =
my
>> Dell XPS15 9550. My WiFi doesn't work.
>>
>> Relevant bits of my lsusb & lspci are:
>>
>> $ lsusb
>> ...
>> Bus 001 Device 002: ID 0a5c:6410 Broadcom Corp.
>> ...
>> $ lspci
>> ...
>> 02:00.0 Network controller: Broadcom Corporation BCM43602 802.11ac
>> Wireless LAN SoC (rev 01)
>> ...
>>
>> and here's the first BUG from from dmesg:
>
> Hi Grey,
>
> I have submitted a patch for this a moment ago. You can find it here =
[1]
> as well. Let me know if it works for you.
>
> Regards,
> Arend
>
> [1]
> http://mid.gmane.org/1464815616-21551-1-git-send-email-arend@broadcom=
=2Ecom

Hi Arend,
That patch solves the issue for me. Thanks very much!
=C2=ACgrey
