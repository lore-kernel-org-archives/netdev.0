From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: iproute2: adding /128 address to sit interface borks
Date: Fri, 10 Jul 2009 08:27:31 -0700
Message-ID: <20090710082731.0b06c0eb@nehalam>
References: <alpine.LSU.2.00.0907101402430.21999@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51113 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753725AbZGJP1i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jul 2009 11:27:38 -0400
In-Reply-To: <alpine.LSU.2.00.0907101402430.21999@fbirervta.pbzchgretzou.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 10 Jul 2009 14:05:01 +0200 (CEST)
Jan Engelhardt <jengelh@medozas.de> wrote:

> Hi,
> 
> 
> it's impossible to do this, and the error message does not say why 
> that is so. No word in dmesg either.
> 
> 
> # ip a a fc00::49/128 peer fc00::7 dev sit7
> RTNETLINK answers: Invalid argument

You will need to walk through the path in the kernel.
In worst case, it means adding kernel printk's.

Then if you want to be nice, make a patch to ipaddr.c in iproute
utilities so command line can find the error before passing to
kernel and give a nice error :-)

-- 
