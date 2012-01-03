From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [net-next 08/11] e1000e: add Receive Packet Steering (RPS)
 support
Date: Tue, 3 Jan 2012 20:16:44 +0000
Message-ID: <804857E1F29AAC47BF68C404FC60A1840292A5@ORSMSX102.amr.corp.intel.com>
References: <1325618356-2655-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1325618356-2655-9-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120103.150936.572765552893657192.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:38984 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755087Ab2ACUQq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 15:16:46 -0500
In-Reply-To: <20120103.150936.572765552893657192.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Tuesday, January 03, 2012 12:10 PM
>To: Kirsher, Jeffrey T
>Cc: Allan, Bruce W; netdev@vger.kernel.org; gospo@redhat.com;
>sassmann@redhat.com
>Subject: Re: [net-next 08/11] e1000e: add Receive Packet Steering (RPS) support
>
>From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>Date: Tue,  3 Jan 2012 11:19:13 -0800
>
>> +		e_err("Enabling both receive checksum offload and receive hashing is
>not possible with jumbo frames.  Disable jumbos or enable only one of the
>receive offload features.\n");
>
>Please split this up into multiple lines like this:
>
>	e_err("..."
>	      "..."
>	      "...");
>
>Thanks.

I was under the impression from recently accepted patches that the preferred
method for log/error message strings was to keep them as a single string
(rather than broken across multiple lines) for easy searching.  Is that not
the case here?

>From ./Documentation/CodingStyle..."never break user-visible strings such as
printk messages, because that breaks the ability to grep for them."

Do you still want this change?

Thanks,
Bruce.
