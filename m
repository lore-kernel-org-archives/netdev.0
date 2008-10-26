From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: IPv6 multicast forwarding
Date: Sun, 26 Oct 2008 12:26:27 +0200 (EET)
Message-ID: <alpine.LRH.2.00.0810261225230.516@netcore.fi>
References: <50a66e370810231511m10a10ca2oa870e9fbd55f4b0e@mail.gmail.com>  <20081024111044.74c15155@varda>  <alpine.LRH.2.00.0810241307360.1106@netcore.fi> <50a66e370810240606ncb3dcd6gc949b734b1dcf488@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: =?ISO-8859-15?Q?Alejandro_Riveira_Fern=E1ndez?=
	<ariveira@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Todd Hayton <todd.hayton@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:54601 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752325AbYJZK0d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Oct 2008 06:26:33 -0400
In-Reply-To: <50a66e370810240606ncb3dcd6gc949b734b1dcf488@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 24 Oct 2008, Todd Hayton wrote:
> Hey there, thanks for the response! I may be misinterpreting the RFC
> but I thought ff15::1 was a site-local address. As in I break down
> ff15::1 as follows -
>
> 0xff : identifies the address as multicast
> 0x15 : 4-bits flags and 4-bits scope where
>  flags = 0x1 meaning that the T bit is set as this address is not a
> permanently assigned address
>  scope = 0x5 indicating site-local scope

You're right.  The nibbles got switched in my head.  Sorry for that.
