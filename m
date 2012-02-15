From: Nick Bowler <nbowler@elliptictech.com>
Subject: Re: Bogus frames transmitted with r8169 & fragmentation & large mtu
Date: Wed, 15 Feb 2012 18:34:08 -0500
Message-ID: <20120215233408.GA8389@elliptictech.com>
References: <20120215163748.GA3998@elliptictech.com>
 <20120215224122.GA31463@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.scalarmail.ca ([98.158.95.75]:33946 "EHLO
	ironport-01.sms.scalar.ca" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753457Ab2BOXeR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 18:34:17 -0500
Content-Disposition: inline
In-Reply-To: <20120215224122.GA31463@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2012-02-15 23:41 +0100, Francois Romieu wrote:
> Nick Bowler <nbowler@elliptictech.com> :
> [...]
> > Let me know if you need any more info,
> 
> Please send the XID line from the r8169 driver for this device.

This one?

  [   10.344571] r8169 0000:02:00.0: eth0: RTL8168d/8111d at 0xf8064000, bc:ae:c5:27:19:6f, XID 083000c0 IRQ 41

> Did you enable some offload feature (see 'ethtool -k') ?

Not beyond the defaults as far as I know.  Here's the ethtool -k output:

  Offload parameters for p10p1:
  rx-checksumming: on
  tx-checksumming: off
  scatter-gather: off
  tcp-segmentation-offload: off
  udp-fragmentation-offload: off
  generic-segmentation-offload: off
  generic-receive-offload: on
  large-receive-offload: off
  rx-vlan-offload: on
  tx-vlan-offload: on
  ntuple-filters: off
  receive-hashing: off

Thanks,
-- 
Nick Bowler, Elliptic Technologies (http://www.elliptictech.com/)
