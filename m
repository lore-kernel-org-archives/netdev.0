From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [openib-general] Re: LLTX and netif_stop_queue
Date: Thu, 20 Jan 2005 02:17:30 +0100
Message-ID: <20050120011729.GA6775@electric-eye.fr.zoreil.com>
References: <5cac192f05010308414a25b548@mail.gmail.com> <527jmu8nbw.fsf@topspin.com> <5cac192f0501030907c755135@mail.gmail.com> <20050103171227.GD7370@esmail.cup.hp.com> <1104812294.1085.53.camel@jzny.localdomain> <20050119144711.3fdd3d93.davem@davemloft.net> <20050119151853.259de49a@dxpl.pdx.osdl.net> <20050119154132.68f0bb4f.davem@davemloft.net> <20050120004753.GB2330@electric-eye.fr.zoreil.com> <20050119165247.5d4cec51.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, hadi@cyberus.ca, iod00d@hp.com,
        eric.lemoine@gmail.com, roland@topspin.com, netdev@oss.sgi.com,
        ak@suse.de, openib-general@openib.org, kaber@trash.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050119165247.5d4cec51.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> :
[...]
> Hmmm... ok then.  Unfortunately, my prototype patch I just posted
> will make IRQs get disabled in the ->hard_start_xmit() path.

I'm completely fine with the prototype patch. It will allow to cut some
code in the driver and the r8169 has room for improvement anyway.

Point taken for the close() routine.

--
Ueimor
