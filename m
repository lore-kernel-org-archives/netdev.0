From: Richard Weinberger <richard.weinberger@gmail.com>
Subject: Re: [PATCH net-next] hyperv: Add handler for
 RNDIS_STATUS_NETWORK_CHANGE event
Date: Tue, 27 Oct 2015 23:36:08 +0100
Message-ID: <CAFLxGvwjhxxc2OgerCeF4nmvpbTV1-XttUZ2poaDLFWcBpaOxw@mail.gmail.com>
References: <06b508cbb6b949f4b3e13e7797948e56@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140623131723.GA7026@aepfle.de>
 <5fb9ddebb68d456ab87979b5cc3830ec@DFM-DB3MBX15-06.exchange.corp.microsoft.com>
 <20140623.131018.1349792926453695313.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 driverdev-devel@linuxdriverproject.org, LKML <linux-kernel@vger.kernel.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 Haiyang Zhang <haiyangz@microsoft.com>
To: David Miller <davem@davemloft.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140623.131018.1349792926453695313.davem@davemloft.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

On Mon, Jun 23, 2014 at 10:10 PM, David Miller <davem@davemloft.net> wrote:
> From: Haiyang Zhang <haiyangz@microsoft.com>
> Date: Mon, 23 Jun 2014 16:09:59 +0000
>
>> So, what's the equivalent or similar command to "network restart" on SLES12? Could
>> you update the command line for the usermodehelper when porting this patch to SLES
>> 12?
>
> No, you are not going to keep the usermodehelper invocation in your driver
> please remove it.  It is absolutely inappropriate, and I strictly do not want
> to keep it in there because other people will copy it and then we'll have a
> real mess on our hands.

Sorry for digging up this old thread.
While talking with some guys about usermodehelper abuses I came across this gem.
Mainline still contains that "/etc/init.d/network restart" code.
Haiyang, care to cleanup?

-- 
Thanks,
//richard
