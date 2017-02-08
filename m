From: "Grandhi, Sainath" <sainath.grandhi@intel.com>
Subject: RE: [PATCHv4 0/7] Refactor macvtap to re-use tap functionality by
 other virtual intefaces
Date: Wed, 8 Feb 2017 21:41:19 +0000
Message-ID: <2C5142675EC1274EAB6230F72F8DC95F28CADC16@ORSMSX113.amr.corp.intel.com>
References: <1486416975-14133-1-git-send-email-sainath.grandhi@intel.com>
 <20170207.132822.668043461053676694.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "mahesh@bandewar.net" <mahesh@bandewar.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170207.132822.668043461053676694.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Tuesday, February 07, 2017 10:28 AM
> To: Grandhi, Sainath <sainath.grandhi@intel.com>
> Cc: netdev@vger.kernel.org; mahesh@bandewar.net; linux-
> kernel@vger.kernel.org
> Subject: Re: [PATCHv4 0/7] Refactor macvtap to re-use tap functionality by
> other virtual intefaces
> 
> From: Sainath Grandhi <sainath.grandhi@intel.com>
> Date: Mon,  6 Feb 2017 13:36:08 -0800
> 
> > Tap character devices can be implemented on other virtual interfaces
> > like ipvlan, similar to macvtap. Source code for tap functionality in
> > macvtap can be re-used for this purpose.
> >
> > This patch series splits macvtap source into two modules, macvtap and tap.
> > This patch series also includes a patch for implementing tap character
> > device driver based on the IP-VLAN network interface, called ipvtap.
> >
> > These patches are tested on x86 platform.
> 
> You're going to have to rework the module and Kconfig parts of this set of
> changes.
> 
> The user should not have to modify any existing Kconfig setting to get the
> same set of modules which already exist today.
> 
> Yet when I run "make oldconfig" after applying these changes it prompts me
> for:
> 
>     TAP module support for virtual interfaces (TAP) [N/m/y/?] (NEW)
> 
> And that's not really acceptable.  I had MACVTAP set, I should still get the
> infrastructure necessary to get that module built.
> 
> If you want to do patch #6 you have to do it in a way that is transparent to
> existing kernel configs.

Please check the next version of patches. Modified Kconfig to make TAP as an user non-visible symbol.

> 
> Thanks.
