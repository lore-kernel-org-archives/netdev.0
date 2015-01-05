From: Hubert Sokolowski <hubert.sokolowski@intel.com>
Subject: Re: [PATCH net-next v3] net: Do not call ndo_dflt_fdb_dump if ndo_fdb_dump
 is defined
Date: Mon, 05 Jan 2015 12:57:50 +0000
Message-ID: <54AA8A4E.4030808@intel.com>
References: <54941689.7060100@intel.com> <20141220.150554.88974537269596572.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ray.kinsella@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:16566 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753272AbbAEM5w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2015 07:57:52 -0500
In-Reply-To: <20141220.150554.88974537269596572.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 20/12/14 20:05, David Miller wrote:
> From: Hubert Sokolowski <hubert.sokolowski@intel.com>
> Date: Fri, 19 Dec 2014 12:14:01 +0000
>
>> At the same time it is desirable to call the default dump
>> function on a bridge device.
> Device specific things do not belong in generic code.
>
> If the bridging device wants specific behavior wrt. this
> callback, it can implement the callback as needed.

Will fix it and resend the patch as v4.

Thanks,
Hubert

-- 
Hubert Sokolowski                  Intel Corporation
