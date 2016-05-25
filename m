From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Davicom DM9162 PHY supported in the kernel?
Date: Wed, 25 May 2016 16:03:16 +0200
Message-ID: <20160525140316.GH8897@lunn.ch>
References: <5717C45F.30205@gmail.com>
 <CAOLz05pidfdJXR58a+xjvp02EyPhUJnz9odpM-VFtkCQ2bhtNQ@mail.gmail.com>
 <20160503153659.GA29815@lunn.ch>
 <CAOLz05r-JEk2JV7PONsPhkaxCUankB6XThFgo4DO+gCf1p9c4g@mail.gmail.com>
 <20160509120634.GQ7972@lunn.ch>
 <CAOLz05o5SELBH6LovChQrFXQWXOZANhrYrTNcuktM_nKnp10VQ@mail.gmail.com>
 <20160524163047.GF8897@lunn.ch>
 <CAOLz05rwjEUpeSgUxc9oJYsPaYvmTV96YESc5=yxQtwHRFww6w@mail.gmail.com>
 <20160525123941.GA21924@lunn.ch>
 <CAOLz05ryCqYboVLN7aFKTj6r0H54gNCu43063mS9y+GY8T30Gw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
To: Amr Bekhit <amrbekhit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49441 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753434AbcEYODS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 May 2016 10:03:18 -0400
Content-Disposition: inline
In-Reply-To: <CAOLz05ryCqYboVLN7aFKTj6r0H54gNCu43063mS9y+GY8T30Gw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 25, 2016 at 02:20:58PM +0100, Amr Bekhit wrote:
> Hi Andrew,
> 
> I've uploaded the device tree to http://pastebin.com/tNp2PnW4.

This is the decompiled blob, making it hard to read.

I do however notice that you have two clocks, "hclk", "pclk". The
binding talks of a third optional clock. Is it required for your
hardware?

Also, have you seen:

https://lkml.org/lkml/2015/3/5/499

Are you sure you have the correct compatible string?

    Andrew
