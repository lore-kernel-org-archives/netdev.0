From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: [net 2/2] ixgbe: fix WoL issue with fiber
Date: Mon, 16 Apr 2012 13:57:45 +0000
Message-ID: <F6FB0E698C9B3143BDF729DF2228664610F95232@ORSMSX102.amr.corp.intel.com>
References: <1334393478-31885-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1334393478-31885-3-git-send-email-jeffrey.t.kirsher@intel.com>
 <4F89C659.4080702@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Jan Ceuleers <jan.ceuleers@computer.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:26268 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753278Ab2DPN5r convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2012 09:57:47 -0400
In-Reply-To: <4F89C659.4080702@computer.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Jan Ceuleers [mailto:jan.ceuleers@computer.org]
>Sent: Saturday, April 14, 2012 11:48 AM
>To: Kirsher, Jeffrey T
>Cc: davem@davemloft.net; Skidmore, Donald C; netdev@vger.kernel.org;
>gospo@redhat.com; sassmann@redhat.com
>Subject: Re: [net 2/2] ixgbe: fix WoL issue with fiber
>
>Jeff Kirsher wrote:
>> From: Don Skidmore<donald.c.skidmore@intel.com>
>>
>> There are times we turn of the laser before shutdown.  This is a bad
>thing
>> if we want to wake on lan to work so now we make sure the laser is on
>> before shutdown if we support WoL.
>
>I'm ever-so-sorry if this is a silly question, but:
>
>WOL is receive-only, right? Why does the laser need to be on?
>
>Thanks, Jan

Without the laser on we can't get link and without link we can't get the magic packet to wake us up.

Thanks,
-Don Skidmore <donald.c.skidmore@intel.com>
