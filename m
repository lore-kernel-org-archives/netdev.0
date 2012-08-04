From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Sun, 5 Aug 2012 00:44:05 +0300
Message-ID: <CAJZOPZ+TJ7JLdvmh7a9mNAp0bujv0jQBG+5Aq9aU9MEVOJobeA@mail.gmail.com>
References: <501C3527.6060809@mellanox.com>
	<20120803.143315.151094375569109262.davem@davemloft.net>
	<501C5328.4060301@mellanox.com>
	<20120803.163627.1867181085116225405.davem@davemloft.net>
	<CAJZOPZJ=WPXcEysh-2p+pmY7RJME24zySWHGzGYbOq9LKidvBA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: ali@mellanox.com, ebiederm@xmission.com, ogerlitz@mellanox.com,
	roland@kernel.org, netdev@vger.kernel.org, sean.hefty@intel.com,
	erezsh@mellanox.co.il
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:41759 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753453Ab2HDVoG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Aug 2012 17:44:06 -0400
Received: by obbuo13 with SMTP id uo13so3250814obb.19
        for <netdev@vger.kernel.org>; Sat, 04 Aug 2012 14:44:05 -0700 (PDT)
In-Reply-To: <CAJZOPZJ=WPXcEysh-2p+pmY7RJME24zySWHGzGYbOq9LKidvBA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 5, 2012 at 12:23 AM, Or Gerlitz <or.gerlitz@gmail.com> wrote:

> The idea in eIPoIB was to allow IP apps running on VMs under a Para-Virtual set of
> mind, e.g when the Linux PV networking stack comes into play, to use that stack w.o > modifying it. When looking on that, we thought so far so good, and went in the way
> posted here. If reusing your last sentence... this driver provides a way for apps to use
> the PV stack AND IB whilst using something familiar, like IPv4.

OK, when I said the PV stack, I meant the portion of the PV stack
which assumes Ethernet link layer, ofcourse... If someone uses routing
they don't need this driver.

Again, since the app only uses IP,  which is well defined, etc. the
work done by the eipoib driver, didn't seem as hackish messing, so I'm
again with that WW (Why/What) question from 5m ago.

Or.
