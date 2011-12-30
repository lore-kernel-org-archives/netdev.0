From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/1] via-rhine: Fix hanging with high CPU load on low-end broads.
Date: Fri, 30 Dec 2011 23:08:30 +0100
Message-ID: <20111230220830.GA5935@electric-eye.fr.zoreil.com>
References: <CACPM=kV8NwYLAdODQHxYmJ21X0RmZ8KJT9szKdY2xa-DsesvQg@mail.gmail.com> <CACPM=kVfsXgFhKheevTS1pm7kCoezKO3M+102O=PRbXzxebxxg@mail.gmail.com> <20111229235312.GA27092@electric-eye.fr.zoreil.com> <CACPM=kXTqY1kVWrEMB-Z0Lqy6t+rXvMzixcSUy7fAz6g_ajV9g@mail.gmail.com> <20111230125655.GA32031@electric-eye.fr.zoreil.com> <CACPM=kVBxcL1_Z9zVvnEEdEgAc0rbAAbzkcocz4OYWQ2xn6VmQ@mail.gmail.com> <20111230180347.GA3647@electric-eye.fr.zoreil.com> <CACPM=kXWXUE+JcVhkz-6tGZ2YyteN9sGA80+Pnw6+LaJ-eNWBA@mail.gmail.com> <20111230215024.GA5513@electric-eye.fr.zoreil.com> <CACPM=kUGEqNnVz+-Re0smWgVmZPJfTDWFbbAQp04JAK5E5=PNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	bhutchings@solarflare.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, rl@hellgate.ch
To: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CACPM=kUGEqNnVz+-Re0smWgVmZPJfTDWFbbAQp04JAK5E5=PNw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bjarke Istrup Pedersen <gurligebis@gentoo.org> :
[...]
> Applied the patch, testing later :)
> You are saying that with CONFIG_PM disabled, I wont be able to bring
> the interface down and up again?

No. You would not see the message with CONFIG_PM but the down / up problem
would still be there. The patch should fix the down / up problem.

/away

-- 
Ueimor
