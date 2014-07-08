From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] hyperv: Add netpoll support
Date: Wed, 9 Jul 2014 01:43:38 +0200
Message-ID: <20140708234338.GA4181@electric-eye.fr.zoreil.com>
References: <1404811947-5174-1-git-send-email-richard@nod.at>
 <9fb91c2ee32a4a59a2bec54043a6b9fd@BY2PR03MB299.namprd03.prod.outlook.com>
 <53BC3AC5.6000203@nod.at>
 <b2835410139848be8811403e3d7fa708@BY2PR03MB299.namprd03.prod.outlook.com>
 <53BC51B4.4010703@nod.at>
 <20140708224724.GA2994@electric-eye.fr.zoreil.com>
 <53BC7666.3050408@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
 Haiyang Zhang <haiyangz@microsoft.com>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Richard Weinberger <richard@nod.at>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <53BC7666.3050408@nod.at>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Richard Weinberger <richard@nod.at> :
> Am 09.07.2014 00:47, schrieb Francois Romieu:
[...]
> > What are you taking about ? netconsole does not need to receive.
> 
> Isn't netconsole is only one user of netpoll ?

Out of tree users are irrelevant. See netpoll related comments in
cd6362befe4cc7bf589a5236d2a780af2d47bcc9

> Of course netconsole needs only to transmit SKBs.
> But if you look at other ->ndo_poll_controller implementations
> you'll notice that they care also about receiving.

It's just the long, illuminating history of netpoll :o)

Some limited Rx netpoll support may be done but it needs more work
than was originally advertised.

> > hyperv start_xmit handler almost does its own Tx completion as you have
> > noticed. The situation is imho close to a virtual device one as was veth
> > in bb446c19fefd7b4435adb12a9dd7666adc5b553a.
> 
> Bad commit reference: bb446c19fefd7b4435adb12a9dd7666adc5b553a

Sorry, it currently belongs to davem's net-next.

-- 
Ueimor
