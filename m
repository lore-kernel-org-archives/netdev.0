From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC 4/6] mlx4: Implement devlink interface
Date: Tue, 16 Feb 2016 17:51:10 +0100
Message-ID: <20160216165110.GG2227@nanopsycho.orion>
References: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
 <1454496482-13961-5-git-send-email-jiri@resnulli.us>
 <56C351C9.9010203@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, yishaih@mellanox.com,
	dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, jbenc@redhat.com
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:32912 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754641AbcBPQvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 11:51:13 -0500
Received: by mail-wm0-f48.google.com with SMTP id g62so200244814wme.0
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 08:51:12 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <56C351C9.9010203@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Feb 16, 2016 at 05:43:53PM CET, ogerlitz@mellanox.com wrote:
>On 2/3/2016 12:48 PM, Jiri Pirko wrote:
>>Implement newly introduced devlink interface. Add devlink port instances
>>for every port and set the port types accordingly.
>>
>
>Lets see how to use the newly introduced interface in a way which would allow
>us to get a configuration
>profile from user-space and program it to the firmware. This is generic
>problem for other drivers too - we've triedsolving it with configfs in the
>past but the patches were not accepted.

That we plan to do for mlxsw as well via devlink. That will be in a
follow-up patchset.
