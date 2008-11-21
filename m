From: "=?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?=" <gotzoncabanes@gmail.com>
Subject: Re: How to use ixp4xx_hss (or generic-hdlc?)
Date: Fri, 21 Nov 2008 09:18:43 +0100
Message-ID: <b0438a630811210018j38518462ve975dfd3a7220b00@mail.gmail.com>
References: <b0438a630811200942nac803a4hb0c054bf28195cb3@mail.gmail.com>
	 <20081120222431.GA16068@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, khc@pm.waw.pl
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.250]:41649 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752381AbYKUISo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 03:18:44 -0500
Received: by an-out-0708.google.com with SMTP id d40so374463and.1
        for <netdev@vger.kernel.org>; Fri, 21 Nov 2008 00:18:43 -0800 (PST)
In-Reply-To: <20081120222431.GA16068@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi and thanks for the answer.

On Thu, Nov 20, 2008 at 11:24 PM, Francois Romieu <romieu@fr.zoreil.com=
> wrote:
> Miguel =C1ngel =C1lvarez <gotzoncabanes@gmail.com> :
> [...]
>> Is there any kind of tutorials on using generic-hdlc interfaces?
>
> Google + ixp4xx_hss + sethdlc -> first entry

Ummm? Not for me at least. If I do that I only find my previous post
and some information about goramo platform in polish (made by
krzysztof.

>
> http://www.kernel.org/pub/linux/utils/net/hdlc/

Yes... I checked that in the beginning, and there is where I found the
need to use sethdlc and the basic processes. (By the way... I do not
have the problem in ifconfig-ing up the interface... I just were
forgetting to so "sethdlc hdlc0 hdlc" previously).
>
> The DSCC4 mini-HOWTO is rather old but it is imho a decent intro
> if you are a bit lost.
>

I also checked it, and I found it very illustrating. Good work of
=46rantisek (based on yours and Krzysztof's).

I have also taken a look to the code of sethdlc to see how the socket
to the interface was set. He made "sock =3D socket(PF_INET, SOCK_DGRAM,
IPPROTO_IP);" which I suppose does not care a lot because sethdlc only
uses the socket to send ioctls, and not any data transfers.

However, in my case, I need to send data in a non-IP world using the
interface. So... Is this the way I should open the socket? Would this
encapsulate my data in hdlc before sending it to the interface?

if I open the socket using sock =3D socket(PF_PACKET, SOCK_RAW,
htons(ETH_P_ALL)); I can send data into the interface, but it is just
sent as raw data (which is logic).

So... yes... I am a bit lost in this point.

Thanks

Miguel =C1ngel =C1lvarez
