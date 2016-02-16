From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [patch net-next RFC 4/6] mlx4: Implement devlink interface
Date: Tue, 16 Feb 2016 18:43:53 +0200
Message-ID: <56C351C9.9010203@mellanox.com>
References: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
 <1454496482-13961-5-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<idosch@mellanox.com>, <eladr@mellanox.com>, <yotamg@mellanox.com>,
	<yishaih@mellanox.com>, <dledford@redhat.com>,
	<sean.hefty@intel.com>, <hal.rosenstock@gmail.com>,
	<eugenia@mellanox.com>, <roopa@cumulusnetworks.com>,
	<nikolay@cumulusnetworks.com>, <hadarh@mellanox.com>,
	<jhs@mojatatu.com>, <john.fastabend@gmail.com>,
	<jeffrey.t.kirsher@intel.com>, <jbenc@redhat.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0064.outbound.protection.outlook.com ([157.55.234.64]:22656
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932117AbcBPQoO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 11:44:14 -0500
In-Reply-To: <1454496482-13961-5-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/3/2016 12:48 PM, Jiri Pirko wrote:
> Implement newly introduced devlink interface. Add devlink port instances
> for every port and set the port types accordingly.
>

Lets see how to use the newly introduced interface in a way which would 
allow us to get a configuration
profile from user-space and program it to the firmware. This is generic 
problem for other drivers too - we've triedsolving it with configfs in 
the past but the patches were not accepted.

Or.
