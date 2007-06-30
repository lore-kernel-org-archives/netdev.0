From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: [PATCH] b44: power down PHY when interface down
Date: Sat, 30 Jun 2007 07:44:59 -0700
Message-ID: <46866C6B.9010801@linux.intel.com>
References: <4354d3270706300447ladcda4by987b1f87963112f9@mail.gmail.com> <20070630120541.GA21339@srcf.ucam.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?T=F6r=F6k_Edvin?= <edwintorok@gmail.com>,
	netdev@vger.kernel.org, power@bughost.org, zambrano@broadcom.com,
	linux-kernel@vger.kernel.org
To: Matthew Garrett <mjg59@srcf.ucam.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:55183 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756854AbXF3Oqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jun 2007 10:46:47 -0400
In-Reply-To: <20070630120541.GA21339@srcf.ucam.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matthew Garrett wrote:
> On Sat, Jun 30, 2007 at 02:47:35PM +0300, T=F6r=F6k Edvin wrote:
>> When the interface is down (or driver removed), the BroadCom 44xx ca=
rd=20
>> remains
>> powered on, and both its MAC and PHY is using up power.
>> This patch makes the driver issue a MAC_CTRL_PHY_PDOWN when the inte=
rface
>> is halted, and does a partial chip reset turns off the activity LEDs=
 too.
>=20
> Do you still get link beat detection when the phy is powered down?
>=20
does that matter?
If the interface is down, nic drivers aren't expected to detect=20
link... if userspace wants to find link status it should have the=20
interface up.
