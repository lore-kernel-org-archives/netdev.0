From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 8/9] isdn: Remove unused variable causing a compile
 build warning
Date: Mon, 05 Nov 2012 10:11:44 +0100
Message-ID: <1352106704.1434.25.camel@x61.thuisdomein>
References: <20121103224832.GA24262@gmail.com>
	 <1352024091.1434.17.camel@x61.thuisdomein>
	 <20121104105332.GC27124@gmail.com>
	 <20121104.123013.700345271120279281.davem@davemloft.net>
	 <20121105084419.GC2699@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	isdn@linux-pingi.de, netdev@vger.kernel.org
To: Lee Jones <lee.jones@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121105084419.GC2699@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-11-05 at 09:44 +0100, Lee Jones wrote:
> On Sun, 04 Nov 2012, David Miller wrote:
> > I think the most appropriate thing to do is make CONFIG_ISDN depend
> > upon CONFIG_NETDEVICES in the Kconfig file.
> 
> ... and then remove the CONFIG_NETDEVICES guards in isdn_common.c?

If ISDN would depend on NETDEVICES, ISDN_I4L would too, since it depends
on ISDN. In that case CONFIG_NETDEVICES would always be true when
compiling isdn_common.c. That would make these guards pointless. (The
dependency of ISDN_PPP on NETDEVICES would then also be pointless.)


Paul Bolle
