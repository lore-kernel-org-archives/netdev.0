From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: Re: [PATCH v2 2/3] net: Add Keystone NetCP ethernet driver
Date: Fri, 22 Aug 2014 15:50:25 -0400
Message-ID: <53F79F01.6090804@ti.com>
References: <1408115562-22487-1-git-send-email-santosh.shilimkar@ti.com>	<1408115562-22487-3-git-send-email-santosh.shilimkar@ti.com> <20140821194838.32f2c3f1@uryu.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <robh+dt@kernel.org>,
	<grant.likely@linaro.org>, <devicetree@vger.kernel.org>,
	<sandeep_n@ti.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140821194838.32f2c3f1@uryu.home.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 21 August 2014 10:48 PM, Stephen Hemminger wrote:
> On Fri, 15 Aug 2014 11:12:41 -0400
> Santosh Shilimkar <santosh.shilimkar@ti.com> wrote:
> 
>> NetCP driver has a plug-in module architecture where each of the NetCP
>> sub-modules exist as a loadable kernel module which plug in to the netcp
>> core. These sub-modules are represented as "netcp-devices" in the dts
>> bindings. It is mandatory to have the ethernet switch sub-module for
>> the ethernet interface to be operational. Any other sub-module like the
>> PA is optional.
> 
> What are you doing to prevent/discourage proprietary binary only
> sub-modules?
> 
Not sure if you mistook this infrastructure as a replacement for the
kernel module. The sub modules are traditional kernel modules that
just registers into the NetCP framework. Kernel module infrastructure
already discourages the proprietary binary only sub-modules.

Regards,
Santosh
