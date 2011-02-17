From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: ixgbe: 82599 and Westmere with HT
Date: Thu, 17 Feb 2011 14:06:05 -0800
Message-ID: <29F4ED941D916B48B88B4D2A4F3D1B9C01D2F2FE80@orsmsx509.amr.corp.intel.com>
References: <AANLkTi=1d8aJoFU7gsNy-sYjJomGp-Xz4K+ddKSOk-ir@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Andrew Dickinson <andrew@whydna.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35951 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751728Ab1BQWGH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 17:06:07 -0500
In-Reply-To: <AANLkTi=1d8aJoFU7gsNy-sYjJomGp-Xz4K+ddKSOk-ir@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hey Andrew,

Sorry about the slow reply I'm a bit backed up right now. :)

It sounds like you could be using using RSS hashing?  It's limited to 16 indices.  If you are using Flow Director hashing then maybe your flows aren't varying enough, although from your description it sounds as if they should be.  What if you try something like 'netperf -t TCP_CRR'.

Let me know if any of my assumptions are incorrect.

Thanks,
-Don Skidmore <donald.c.skidmore@intel.com>


>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
>On Behalf Of Andrew Dickinson
>Sent: Wednesday, February 16, 2011 5:22 PM
>To: netdev@vger.kernel.org
>Subject: ixgbe: 82599 and Westmere with HT
>
>Hi,
>
>I've got a dual Westmere board (X5675) with an X520 card with dual
>10G.  I see 24-cores exposed to me and the ixgbe driver exposes 24 tx
>and 24 rx interrupts per NIC.  I then pin the interrupts to cores for
>each NIC (each interrupt gets its own core, standard stuff).
>
>Anyway.... I'm only seeing RX interrupts on 16 of the 24 cores (random
>src/dest pairs across a /16 each, so I should be getting good flow
>hashing).  Did I miss some magic somewhere?
>
>I'm running 2.6.32.4, perhaps this has been fixed upstream.  If not,
>any thoughts on how to make this work?
>
>-A
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
