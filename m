From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: [net-next 03/15] ixgbe: fix fc autoneg ethtool reporting.
Date: Tue, 30 Jul 2013 16:17:57 +0000
Message-ID: <F6FB0E698C9B3143BDF729DF222866466FD39A77@ORSMSX110.amr.corp.intel.com>
References: <1375102331-23905-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1375102331-23905-4-git-send-email-jeffrey.t.kirsher@intel.com>
 <20130729.221833.2091004041005201998.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:50862 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752310Ab3G3QSB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 12:18:01 -0400
In-Reply-To: <20130729.221833.2091004041005201998.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, July 29, 2013 10:19 PM
> To: Kirsher, Jeffrey T
> Cc: Skidmore, Donald C; netdev@vger.kernel.org; gospo@redhat.com;
> sassmann@redhat.com
> Subject: Re: [net-next 03/15] ixgbe: fix fc autoneg ethtool reporting.
> 
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Mon, 29 Jul 2013 05:51:59 -0700
> > @@ -67,15 +67,39 @@ static s32 ixgbe_disable_pcie_master(struct
> ixgbe_hw *hw);
> >   **/
> >  s32 ixgbe_device_supports_autoneg_fc(struct ixgbe_hw *hw)  {
> > +	bool supported = false;
>  ...
> > +	return supported;
> 
> If the function is returning bool, fix the function's return type from 's32' to
> 'bool'.
> 
> 
> > -		    (ixgbe_device_supports_autoneg_fc(hw) == 0)) {
> > +		    (ixgbe_device_supports_autoneg_fc(hw))) {
> 
> I think the outermost parenthesis in
> "(ixgbe_device_supports_autoneg_fc(hw))"
> should be removed.

Thanks Dave, I'll clean this up and send the new patches to Jeff.

-Don Skidmore <donald.c.skidmore>
