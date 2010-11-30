From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH 1/2] ixgb: Don't check for vlan group on transmit.
Date: Tue, 30 Nov 2010 15:52:20 -0700
Message-ID: <EA929A9653AAE14F841771FB1DE5A13660288B58E9@rrsmsx501.amr.corp.intel.com>
References: <1288464591-31528-1-git-send-email-jesse@nicira.com>
	<1288984304.3091.11.camel@jtkirshe-MOBL1>
	<AANLkTin62WWL+cnLVNaOYmcvL28rfkUDVCVqiimSPZ=e@mail.gmail.com>
	<1288987609.3091.16.camel@jtkirshe-MOBL1>
	<80769D7B14936844A23C0C43D9FBCF0F25BD180E03@orsmsx501.amr.corp.intel.com>
	<AANLkTin5YMqpq0h-2HQ8XgaheYYDeMUFv8Qo6fZdWhxB@mail.gmail.com>
 <AANLkTik43SPbQiTxOQPTsUq9hu7h3EgbZ1cvxh=nsFPM@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Jesse Gross <jesse@nicira.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:25612 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752863Ab0K3Wwa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 17:52:30 -0500
In-Reply-To: <AANLkTik43SPbQiTxOQPTsUq9hu7h3EgbZ1cvxh=nsFPM@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesse Gross wrote:
> On Mon, Nov 8, 2010 at 11:59 AM, Jesse Gross <jesse@nicira.com> wrote=
:
>> On Fri, Nov 5, 2010 at 3:30 PM, Duyck, Alexander H
>>> The quick fix for your patch is to move the addition of
>>> VLAN_TAG_SIZE to the max_frame in igb_change_mtu instead of in the
>>> set_rlpml call. =A0Otherwise I will see about submitting an updated
>>> patch in the next few days.  =20
>>=20
>> I happy to let you take care of it - obviously you know the
>> driver/hardware much better than I.
>=20
> Alex, did you get a chance to take a look at this?  I was hoping to
> get the fix for this (and also the patch mentioned originally in this
> message for ixgb) into 2.6.37.  I can also respin it along the lines
> that you suggested if that would help.

Jesse, I am still looking at the ixgb patch. I think the patch is=20
incomplete.

Simply removing the adapter->vlgrp check is not enough. According to=20
the specs CTRL0_VME needs to be set in order for the vlan tag insertion=
/stripping to be enabled. We have a modified patch currently=20
in test and will post it to netdev as soon as we confirm that it works=20
as expected.

Thanks,
Emil