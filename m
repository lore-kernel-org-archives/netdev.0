From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH] Hyperv: Trigger DHCP renew after host hibernation
Date: Mon, 21 Jul 2014 10:17:49 +0200
Message-ID: <53CCCCAD.7080906@nod.at>
References: <1405680903-28176-1-git-send-email-yuezha@microsoft.com>
 <CAFLxGvxQU_z+mChHsNSu9VZEdXrU+RU75k6H18uKbdAj2TKD5g@mail.gmail.com>
 <DC7803B42427924284F2D5252E076A3B44769DCA@SINEX14MBXC416.southpacific.corp.microsoft.com>
 <53CCB944.8090709@nod.at>
 <DC7803B42427924284F2D5252E076A3B4476A363@SINEX14MBXC416.southpacific.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 "driverdev-devel@linuxdriverproject.org"
 <driverdev-devel@linuxdriverproject.org>,
 Haiyang Zhang <haiyangz@microsoft.com>, LKML <linux-kernel@vger.kernel.org>,
 Thomas Shao <huishao@microsoft.com>, Greg KH <gregkh@linuxfoundation.org>,
 "David S. Miller" <davem@davemloft.net>
To: "Yue Zhang (OSTC DEV)" <yuezha@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <DC7803B42427924284F2D5252E076A3B4476A363@SINEX14MBXC416.southpacific.corp.microsoft.com>
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

Yue,

Am 21.07.2014 10:05, schrieb Yue Zhang (OSTC DEV):
> The problem of systemd implementation is that in different distros, the ways to 
> restart service are different. Propagating the event to userspace also doesn't help
> for this issue. 

This way each distro can provide their own restart script.
Same as every distro has custom start scripts, etc...

> The advantage of current solution is that it simulates a cable plugging in/out event.
> IMHO, in all the distros, this simulated event has already been well handled. It is a
> dup effect to implement new hooks.

Iff the current solution works for _all_ networking implementations.

Thanks,
//richard
