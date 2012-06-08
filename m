From: Dustin Schumm <shodid@gmail.com>
Subject: Re: Reoccuring kern.log events after running xl2tp with ethernet
 adapter Realtek 8111E
Date: Fri, 8 Jun 2012 13:56:25 -0400
Message-ID: <CANcVnzjkVSef88Fanr4tNiKB6sfma_HM5aGfRE4GkmL7YFbfXg@mail.gmail.com>
References: <CANcVnzi2mXKXZLcaAt9rJ9OOdK_2=V8JV9uebVeBcsDu6j+DhQ@mail.gmail.com>
	<CANcVnzivnQrhSderZ+b5yoy+F1OiO7Ajv7WeijqzQKyAkYRqug@mail.gmail.com>
	<20120605153753.GA12514@electric-eye.fr.zoreil.com>
	<CANcVnzj-DUD8x9jcj3awyWkZjH9x5PMf3fAFtR_osPNAU9adgA@mail.gmail.com>
	<CANcVnzjKCn00kF8NG+ZLLrzGCs_jx7WYPKyM7uwrxJ=kVLiQ4Q@mail.gmail.com>
	<20120606222529.GA13420@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:40770 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761315Ab2FHR40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 13:56:26 -0400
Received: by weyu7 with SMTP id u7so765159wey.19
        for <netdev@vger.kernel.org>; Fri, 08 Jun 2012 10:56:25 -0700 (PDT)
In-Reply-To: <20120606222529.GA13420@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 6, 2012 at 6:25 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> Dustin Schumm <shodid@gmail.com> :
> [...]
>> Do you see any indication if this is a problem with the mainline
>> kernel, distro kernel, driver, or otherwise? It's not definitive, been
>> I've been good using kernels 2.6.x and getting errors on everything
>> 3.x I have tried. I am looking for some direction to pursue. Thanks.
>
> See http://marc.info/?l=linux-kernel&m=133897670115862&w=2
>
> --
> Ueimor

After further investigation of "EIP is at aesni_cbc_dec"
I changed the ipsec encryption to 3des and l2tp is working properly
now under kernels 3.x
It is strange that the aes module errors do not occur when used with
ipsec alone. It is not until l2tp is initiated that the errors start.
