From: "David S. Miller" <davem@redhat.com>
Subject: Re: Regarding SET_NETDEV_DEV
Date: Tue, 03 Jun 2003 20:46:12 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030603.204612.48501825.davem@redhat.com>
References: <20030603175921.GE2079@gtf.org>
	<20030603.200944.78736971.davem@redhat.com>
	<3EDD6B51.9070909@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: shemminger@osdl.org
In-Reply-To: <3EDD6B51.9070909@osdl.org>
List-Id: netdev.vger.kernel.org

   From: Stephen Hemminger <shemminger@osdl.org>
   Date: Tue, 03 Jun 2003 20:45:21 -0700

   There are enough PCI network devices, that something like 
   alloc_pci_etherdev might
   be a good future idea.
   
What is sos special about PCI? :-)

In this light, alloc_device_etherdev() seems much more appropriate.

But we can play this game AD_INFINITUM, for each and every paramter
that is common across a class of ethernet devices.  At what point
do you stop? :-)
