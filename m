From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [net-next 07/11] e1000e: cleanup Rx checksum offload code
Date: Tue, 3 Jan 2012 20:17:16 +0000
Message-ID: <804857E1F29AAC47BF68C404FC60A18402A6C5@ORSMSX102.amr.corp.intel.com>
References: <1325618356-2655-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1325618356-2655-8-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120103.150842.1516759599032629705.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:25374 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755156Ab2ACURS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 15:17:18 -0500
In-Reply-To: <20120103.150842.1516759599032629705.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Tuesday, January 03, 2012 12:09 PM
>To: Kirsher, Jeffrey T
>Cc: Allan, Bruce W; netdev@vger.kernel.org; gospo@redhat.com;
>sassmann@redhat.com
>Subject: Re: [net-next 07/11] e1000e: cleanup Rx checksum offload code
>
>From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>Date: Tue,  3 Jan 2012 11:19:12 -0800
>
>> -		__sum16 sum = (__force __sum16)htons(csum);
>> +		__sum16 sum = (__force __sum16)htons(le16_to_cpu(csum));
>
>Looks like a NOP.  It's essentially "cpu_to_le16(le16_to_cpu(csum)" as
>far as I can tell.

OK, I'll look into fixing this.

Thanks,
Bruce.
