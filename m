From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: Re: Using netconsole and getting double prints
Date: Mon, 16 Nov 2009 16:18:35 -0800
Message-ID: <43e72e890911161618p39818606yf163ac687bc5aa43@mail.gmail.com>
References: <43e72e890911051654i19c18bf3nd397662ed79712c4@mail.gmail.com>
	<1257484663.2873.622.camel@calx> <43e72e890911060832k1b831f32w93357c71b370e71c@mail.gmail.com>
	<4AF452B8.7080306@googlemail.com> <43e72e890911060914i6233b71dgd68e228074869096@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Andre Naujoks <nautsch2@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f178.google.com ([209.85.223.178]:60539 "EHLO
	mail-iw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753592AbZKQASt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 19:18:49 -0500
In-Reply-To: <43e72e890911060914i6233b71dgd68e228074869096@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 6, 2009 at 9:14 AM, Luis R. Rodriguez <mcgrof@gmail.com> wrote:
> On Fri, Nov 6, 2009 at 8:45 AM, Andre Naujoks <nautsch2@googlemail.com> wrote:
>
>> I think the intention behind this is for you to check if they are double
>> prints on your end or double sends on the other end.
>
> Ah yeah, good point :)

Sniffed and saw the issue. My local router was echo'ing the message,
solution was to simply add the destination mac address on netconsole
module parameters passed.

  Luis
