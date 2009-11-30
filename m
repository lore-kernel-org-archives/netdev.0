From: Brandon Philips <brandon@ifup.org>
Subject: Re: dmfe/tulip device id overlap
Date: Mon, 30 Nov 2009 14:22:20 -0800
Message-ID: <20091130222219.GA8073@jenkins.domain_not_set.invalid>
References: <20091129.003024.245104886.davem@davemloft.net>
 <20091130065512.GA2792@jenkins.domain_not_set.invalid>
 <da824cf30911300914p2d08b87cr4625e9bc30ec7e5b@mail.gmail.com>
 <20091130.122642.113956563.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: grundler@google.com, tobias@ringis.se, kyle@mcmartin.ca,
	netdev@vger.kernel.org, grundler@parisc-linux.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:38141 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751724AbZK3WW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 17:22:58 -0500
Received: by yxe17 with SMTP id 17so4066947yxe.33
        for <netdev@vger.kernel.org>; Mon, 30 Nov 2009 14:23:04 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20091130.122642.113956563.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12:26 Mon 30 Nov 2009, David Miller wrote:
> From: Grant Grundler <grundler@google.com>
> Date: Mon, 30 Nov 2009 09:14:01 -0800
> > Has anyone posted "lspci -v" output for the "Netra X1 and Sunfire
> > V100" motherboards?
> > 
> > I'm asking because I'm hoping it's possible to disambiguate the add-on
> > cards from
> > LAN-on-Motherboard cases by looking at subsystem vendor and device IDs as well.
> 
>             subsystem-id:  0000434e
>             subsystem-vendor-id:  00004554
>
> Hmmm, what vendor is '0x4554'? :-)

Whoever it is it is the same as the expansion card on non-sparc
boards: SubVendor: pci 0x4554 [1]

Hrm, dead end I guess.

Cheers,

	Brandon

[1] https://bugzilla.novell.com/show_bug.cgi?id=537016#c5
