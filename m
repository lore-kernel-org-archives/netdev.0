From: Aleksander Morgado <aleksander@aleksander.es>
Subject: Re: Understanding what's going on when using a Huawei E173 USB 3G
 web-stick (UMTS/HSPA)
Date: Wed, 12 Nov 2014 12:54:06 +0100
Message-ID: <CAAP7ucKQ6Ta=yd0QRSNdOEdcvTR=0i5HLPZEaF33xYGjDtBxvQ@mail.gmail.com>
References: <CA+icZUXgLhuVSs0aqxi_e=GLZh-zX3JPMhDF+03ctr7O-Ae2og@mail.gmail.com>
	<1415120132.31049.11.camel@dcbw.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: sedat.dilek@gmail.com, Greg KH <greg@kroah.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-usb@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:44814 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193AbaKLLyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 06:54:06 -0500
Received: by mail-oi0-f54.google.com with SMTP id i138so992968oig.41
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2014 03:54:06 -0800 (PST)
In-Reply-To: <1415120132.31049.11.camel@dcbw.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> NetworkManager uses ModemManager for all WWAN control, NM only handles
> the configuration storage and IP addressing parts of the setup.
> ModemManager handles modem hardware detection, capability detection,
> WWAN registration and setup, signal strength reporting, network
> connection initiation, and bearer IP addressing method determination.
>
> If you want more information from ModemManager, you can run "mmcli
> --help" or "mmcli --set-logging=debug".
>

That (mmcli) will only be available in ModemManager >= 1.x, BTW. And
beware of --set-logging=debug, as syslog may limit those if MM sends
too many too fast. In general I usually prefer to ask for --debug
output just in case:
http://www.freedesktop.org/wiki/Software/ModemManager/Debugging/

I saw the reporter talk about Ubuntu Precise (12.04) and Trusty
(14.04), so only in the latter mmcli will be available (if I'm not
mistaken). For Precise, this Ubuntu page shows how to enable debug
logs:
https://wiki.ubuntu.com/DebuggingModemmanager

-- 
Aleksander
https://aleksander.es
