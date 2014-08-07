From: Richard Weinberger <richard.weinberger@gmail.com>
Subject: Re: [PATCH] Hyperv: Trigger DHCP renew after host hibernation
Date: Fri, 8 Aug 2014 00:37:28 +0200
Message-ID: <CAFLxGvyfy1UkxN6_-c_ST7f8n7DvqYsCPKChWmt9CerWb0dh7g@mail.gmail.com>
References: <DC7803B42427924284F2D5252E076A3B4476A479@SINEX14MBXC416.southpacific.corp.microsoft.com>
 <53CCD6F2.6020909@nod.at> <20140721091851.GA28171@aepfle.de>
 <20140721.143225.2040366896972949930.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "olaf@aepfle.de" <olaf@aepfle.de>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "jasowang@redhat.com" <jasowang@redhat.com>,
 driverdev-devel@linuxdriverproject.org, LKML <linux-kernel@vger.kernel.org>,
 huishao@microsoft.com, Greg KH <gregkh@linuxfoundation.org>,
 haiyangz@microsoft.com
To: David Miller <davem@davemloft.net>, Yue Zhang <yuezha@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20140721.143225.2040366896972949930.davem@davemloft.net>
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

On Mon, Jul 21, 2014 at 11:32 PM, David Miller <davem@davemloft.net> wrote:
> From: Olaf Hering <olaf@aepfle.de>
> Date: Mon, 21 Jul 2014 11:18:51 +0200
>
>> On Mon, Jul 21, Richard Weinberger wrote:
>>
>>> My concern is that 10 seconds is maybe not a the right choice.
>>> (As we cannot know all implementations)
>>
>> Until someone reports an issue with it, 10 is fine. Just like 20 or 666.
>
> Wrong, this is policy and belongs in userspace.

The "/etc/init.d/network restart" nonsense now hit Linus' tree.
Yue, what is your proposal to fix that?

-- 
Thanks,
//richard
