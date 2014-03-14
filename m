From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 01/16] ixgbe: add check for netif_carrier_ok in
 ixgbe_xmit_frame
Date: Fri, 14 Mar 2014 17:51:31 -0400 (EDT)
Message-ID: <20140314.175131.1233519777786848021.davem@davemloft.net>
References: <1394790446-31591-2-git-send-email-jeffrey.t.kirsher@intel.com>
	<20140314.145735.289100032884651109.davem@davemloft.net>
	<87618083B2453E4A8714035B62D679924FF2B099@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, asharma@fb.com,
	stable@vger.kernel.org
To: emil.s.tantilov@intel.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <87618083B2453E4A8714035B62D679924FF2B099@FMSMSX105.amr.corp.intel.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Date: Fri, 14 Mar 2014 20:19:38 +0000

> That would work, but what if there are other callers of
> ndo_start_xmit that don't have this check? Handling this in the
> driver takes care of all instances.

netif_carrier_off() is supposed to stop traffic from flowing to
the device.

The qdisc layer should be honoring this property, and my
suspicion is that it is just netpoll operates in the unique
environment that doesn't.
