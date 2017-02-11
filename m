From: "Grandhi, Sainath" <sainath.grandhi@intel.com>
Subject: RE: [PATCHv5 0/7] Refactor macvtap to re-use tap functionality by
 other virtual intefaces
Date: Sat, 11 Feb 2017 00:06:47 +0000
Message-ID: <2C5142675EC1274EAB6230F72F8DC95F28CAEBCA@ORSMSX113.amr.corp.intel.com>
References: <1486589836-53858-1-git-send-email-sainath.grandhi@intel.com>
 <20170209.170741.524666868372427163.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "mahesh@bandewar.net" <mahesh@bandewar.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170209.170741.524666868372427163.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, February 09, 2017 2:08 PM
> To: Grandhi, Sainath <sainath.grandhi@intel.com>
> Cc: netdev@vger.kernel.org; mahesh@bandewar.net; linux-
> kernel@vger.kernel.org
> Subject: Re: [PATCHv5 0/7] Refactor macvtap to re-use tap functionality by
> other virtual intefaces
> 
> From: Sainath Grandhi <sainath.grandhi@intel.com>
> Date: Wed,  8 Feb 2017 13:37:09 -0800
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
> I get rejects on patch #7 when I try to apply this to net-next, please respin.

Please check next version. I have based it on net-next.
There is a change in "net-next" repo with ipvlan_core.c that has not made into "net" repo.
