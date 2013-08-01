From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/4] USBNET: ax88179_178a: enable tso if host supports
 sg dma
Date: Thu, 01 Aug 2013 08:36:40 -0700
Message-ID: <1375371400.10515.155.camel@edumazet-glaptop>
References: <1375267909-30373-1-git-send-email-ming.lei@canonical.com>
	 <1375267909-30373-5-git-send-email-ming.lei@canonical.com>
	 <CANEJEGuY3WzxnN4NEKx0RxAJNPO_hy+yt2AqhuTqHQavmawTcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ming Lei <ming.lei@canonical.com>,
	"David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Oliver Neukum <oneukum@suse.de>,
	Freddy Xin <freddy@asix.com.tw>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>, linux-usb@vger.kernel.org
To: Grant Grundler <grundler@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:37481 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753450Ab3HAPgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 11:36:46 -0400
In-Reply-To: <CANEJEGuY3WzxnN4NEKx0RxAJNPO_hy+yt2AqhuTqHQavmawTcw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-08-01 at 08:30 -0700, Grant Grundler wrote:

> http://lxr.free-electrons.com/source/include/linux/byteorder/generic.h#L111
> http://lxr.free-electrons.com/ident?i=__cpu_to_le32s
> 
> IIRC, cpu_to_leXX() macros return the endian "corrected" value.
> In other words, they need to be assigned to something, no?
> 

Nope, this in in-place byte swapping (for Big Endian only)
