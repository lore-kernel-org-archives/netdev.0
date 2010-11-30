From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 1/2] ixgb: Don't check for vlan group on transmit.
Date: Tue, 30 Nov 2010 14:33:39 -0800
Message-ID: <AANLkTik43SPbQiTxOQPTsUq9hu7h3EgbZ1cvxh=nsFPM@mail.gmail.com>
References: <1288464591-31528-1-git-send-email-jesse@nicira.com>
	<1288984304.3091.11.camel@jtkirshe-MOBL1>
	<AANLkTin62WWL+cnLVNaOYmcvL28rfkUDVCVqiimSPZ=e@mail.gmail.com>
	<1288987609.3091.16.camel@jtkirshe-MOBL1>
	<80769D7B14936844A23C0C43D9FBCF0F25BD180E03@orsmsx501.amr.corp.intel.com>
	<AANLkTin5YMqpq0h-2HQ8XgaheYYDeMUFv8Qo6fZdWhxB@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: "Duyck, Alexander H" <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:61237 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028Ab0K3Wdk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 17:33:40 -0500
Received: by fxm8 with SMTP id 8so1662223fxm.19
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 14:33:39 -0800 (PST)
In-Reply-To: <AANLkTin5YMqpq0h-2HQ8XgaheYYDeMUFv8Qo6fZdWhxB@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 8, 2010 at 11:59 AM, Jesse Gross <jesse@nicira.com> wrote:
> On Fri, Nov 5, 2010 at 3:30 PM, Duyck, Alexander H
>> The quick fix for your patch is to move the addition of VLAN_TAG_SIZ=
E to the max_frame in igb_change_mtu instead of in the set_rlpml call. =
=A0Otherwise I will see about submitting an updated patch in the next f=
ew days.
>
> I happy to let you take care of it - obviously you know the
> driver/hardware much better than I.

Alex, did you get a chance to take a look at this?  I was hoping to
get the fix for this (and also the patch mentioned originally in this
message for ixgb) into 2.6.37.  I can also respin it along the lines
that you suggested if that would help.
