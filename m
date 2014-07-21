From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH] Hyperv: Trigger DHCP renew after host hibernation
Date: Mon, 21 Jul 2014 11:01:38 +0200
Message-ID: <53CCD6F2.6020909@nod.at>
References: <1405680903-28176-1-git-send-email-yuezha@microsoft.com> <CAFLxGvxQU_z+mChHsNSu9VZEdXrU+RU75k6H18uKbdAj2TKD5g@mail.gmail.com> <DC7803B42427924284F2D5252E076A3B44769DCA@SINEX14MBXC416.southpacific.corp.microsoft.com> <53CCB944.8090709@nod.at> <DC7803B42427924284F2D5252E076A3B4476A363@SINEX14MBXC416.southpacific.corp.microsoft.com> <53CCCCAD.7080906@nod.at> <DC7803B42427924284F2D5252E076A3B4476A479@SINEX14MBXC416.southpacific.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"driverdev-devel@linuxdriverproject.org"
	<driverdev-devel@linuxdriverproject.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Greg KH <gregkh@linuxfoundation.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	KY Srinivasan <kys@microsoft.com>,
	Thomas Shao <huishao@microsoft.com>,
	Dexuan Cui <decui@microsoft.com>
To: "Yue Zhang (OSTC DEV)" <yuezha@microsoft.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <DC7803B42427924284F2D5252E076A3B4476A479@SINEX14MBXC416.southpacific.corp.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yue,

Am 21.07.2014 10:44, schrieb Yue Zhang (OSTC DEV):
> Hi, Richard
> 
> IMHO, all networking implementations should handle the cable offline event. Consider
> this situation. I unplugged the network cable and connect it to a new network switch
> after 10 seconds. If the DHCP renew is not triggered, the network will break. I think in 
> normal cases, it should already been handled properly. Unless there is a strong 
> justification for not doing this. In that case, we shouldn't renew DHCP anyway.

I agree that they should handle the cable offline event.
My concern is that 10 seconds is maybe not a the right choice.
(As we cannot know all implementations)

Thanks,
//richard
