From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: Re: [2.6 patch] fix bridge <-> ATM compile error
Date: Wed, 16 Mar 2005 13:24:11 -0500
Message-ID: <200503161824.j2GIOArr007631@ginger.cmf.nrl.navy.mil>
References: <20050316181532.GA3251@stusta.de>
Reply-To: chas3@users.sourceforge.net
Cc: shemminger@osdl.org, bridge@osdl.org,
        linux-atm-general@lists.sourceforge.net, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
To: Adrian Bunk <bunk@stusta.de>
Reply-To: chas3@users.sourceforge.net
Reply-To: chas3@users.sourceforge.net
In-reply-to: <20050316181532.GA3251@stusta.de> 
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20050316181532.GA3251@stusta.de>,Adrian Bunk writes:
>Letting CONFIG_BRIDGE depend on CONFIG_ATM doesn't sound like a good 
>idea, since I doubt all people using the Bridge code require ATM 
>support.

i agree.

>Moving the hooks to the bridge code will give you exactly the same 
>problems the other way round.

how about moving them to a third location like net/core/dev.c?
