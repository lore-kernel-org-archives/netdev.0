From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: shape traffic on tun interfaces
Date: Mon, 2 Aug 2010 16:36:51 +0800
Message-ID: <AANLkTinEs2t6Mh8ZQ2HHpKv-dTr-71813sFvXWu_VqNr@mail.gmail.com>
References: <301941280614170@web105.yandex.ru> <474381280735172@web82.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Cc: alex@digriz.org.uk, lartc@mailman.ds9a.nl, netdev@vger.kernel.org
To: Franchoze Eric <franchoze@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58125 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660Ab0HBIhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 04:37:12 -0400
Received: by wyb39 with SMTP id 39so3022633wyb.19
        for <netdev@vger.kernel.org>; Mon, 02 Aug 2010 01:37:11 -0700 (PDT)
In-Reply-To: <474381280735172@web82.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 2, 2010 at 3:46 PM, Franchoze Eric <franchoze@yandex.ru> wrote:
>>Do the QoS on your next hop router
> There is no next router. And QoS should be on the same machine.
>
>>or on the interface all your de-encapsulated VPN traffic flows over (ie. 'eth0') instead.
>
> It is not a problem to find interface with de-encapsulated traffic. The problem is that tc rules should be written accoring to network device.

try ifb:

config IFB
        tristate "Intermediate Functional Block support"
        depends on NET_CLS_ACT
        ---help---
          This is an intermediate driver that allows sharing of
          resources.
          To compile this driver as a module, choose M here: the module
          will be called ifb.  If you want to use more than one ifb
          device at a time, you need to compile this driver as a module.
          Instead of 'ifb', the devices will then be called 'ifb0',
          'ifb1' etc.
          Look at the iproute2 documentation directory for usage etc

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
