From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: Re: [PATCH net-next v2 1/2] if_link: add client name to port
 profile
Date: Mon, 6 Oct 2014 00:14:30 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1410052339550.5378@ws.cisco>
References: <1412289683-8278-1-git-send-email-_govind@gmx.com> <1412289683-8278-2-git-send-email-_govind@gmx.com> <20141004200523.4fc102e3@urahara>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Govindarajulu Varadarajan <_govind@gmx.com>, davem@davemloft.net,
	netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:57650 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751775AbaJESos (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Oct 2014 14:44:48 -0400
In-Reply-To: <20141004200523.4fc102e3@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 4 Oct 2014, Stephen Hemminger wrote:
> Maybe you could use the existing IFLA_IFALIAS?
> It is already supported by iproute tools and sysfs, and can be used by net-snmp as well.
> You would just be setting the default string, users could change it.
>

I do not think we can use ifalias here. Port profile is for SRIOV-VF
pci passthrough. vfio-pci will own the pci device and there would not be
net_device registeres for that interface on host. The client (libvirt)
unregisters the vf before binding it to vfio-pci.
