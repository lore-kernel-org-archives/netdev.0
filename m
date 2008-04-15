From: =?UTF-8?B?RsOhYmlvIFNvdXRv?= <fsouto@lasige.di.fc.ul.pt>
Subject: Re: Netfilter and IPSec
Date: Tue, 15 Apr 2008 19:45:41 +0100
Message-ID: <4804F7D5.3000305@lasige.di.fc.ul.pt>
References: <480423CD.3060707@lasige.di.fc.ul.pt> <alpine.LNX.1.10.0804151322470.13202@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@computergmbh.de>
Return-path: <netfilter-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.1.10.0804151322470.13202@fbirervta.pbzchgretzou.qr>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
>
>
> The situation is deliberate, yes. IPsec is done in what you could
> call the xfrm subsystem, not netfilter. To that end, the only
> suggestion I could give is that you create a new xfrm policy/state
> from esp where esp is split into your encryption and signing
> "targets".
>
>  =20
Thank you for all answers. The major problem I'm facing is the lacking=20
of documentation on that subsystem.
=46or example, how to create a policy. And after that?
My task is a bit easier, because I only need to use AH and not ESP.
Although a flexible solution would be of value :)

The kernel is still a bit unknown to me, so I'm having a bit of trouble=
=20
into all the jargon you are using around.
But the few things I understood are being extremely helpful.
> It kinda brings me the question why the ipsec transformation is
> not done with an xtables target instead; that would also give
> handy access to connection tracking if needed.
>  =20
With that I must agree!

--=20
-----------------------------------------------------------------------=
-------------------
=46=C3=A1bio Souto
LaSIGE , Navigators Group
Departamento de Inform=C3=A1tica, FC/UL
Block C6, room 6.3.32, Campo Grande
1749-016 Lisboa, Portugal

