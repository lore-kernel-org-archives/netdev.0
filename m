From: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Subject: RE: [PATCH 1/2] ixgb: Don't check for vlan group on transmit.
Date: Wed, 1 Dec 2010 09:40:29 -0800
Message-ID: <80769D7B14936844A23C0C43D9FBCF0F25BD7864D6@orsmsx501.amr.corp.intel.com>
References: <1288464591-31528-1-git-send-email-jesse@nicira.com>
	<1288984304.3091.11.camel@jtkirshe-MOBL1>
	<AANLkTin62WWL+cnLVNaOYmcvL28rfkUDVCVqiimSPZ=e@mail.gmail.com>
	<1288987609.3091.16.camel@jtkirshe-MOBL1>
	<80769D7B14936844A23C0C43D9FBCF0F25BD180E03@orsmsx501.amr.corp.intel.com>
	<AANLkTin5YMqpq0h-2HQ8XgaheYYDeMUFv8Qo6fZdWhxB@mail.gmail.com>
 <AANLkTik43SPbQiTxOQPTsUq9hu7h3EgbZ1cvxh=nsFPM@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:47398 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755445Ab0LARkd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 12:40:33 -0500
In-Reply-To: <AANLkTik43SPbQiTxOQPTsUq9hu7h3EgbZ1cvxh=nsFPM@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Jesse Gross [mailto:jesse@nicira.com]
>Sent: Tuesday, November 30, 2010 2:34 PM
>To: Duyck, Alexander H
>Cc: Kirsher, Jeffrey T; David Miller; netdev@vger.kernel.org;
>Brandeburg, Jesse
>Subject: Re: [PATCH 1/2] ixgb: Don't check for vlan group on transmit.
>
>On Mon, Nov 8, 2010 at 11:59 AM, Jesse Gross <jesse@nicira.com> wrote:
>> On Fri, Nov 5, 2010 at 3:30 PM, Duyck, Alexander H
>>> The quick fix for your patch is to move the addition of
>VLAN_TAG_SIZE to the max_frame in igb_change_mtu instead of in the
>set_rlpml call. =A0Otherwise I will see about submitting an updated
>patch in the next few days.
>>
>> I happy to let you take care of it - obviously you know the
>> driver/hardware much better than I.
>
>Alex, did you get a chance to take a look at this?  I was hoping to
>get the fix for this (and also the patch mentioned originally in this
>message for ixgb) into 2.6.37.  I can also respin it along the lines
>that you suggested if that would help.

I did, and we are currently testing the patch I have generated.  Once i=
t passes testing Jeff will submit it to netdev.

Thanks,

Alex
