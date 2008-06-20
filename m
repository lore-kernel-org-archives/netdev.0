From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH net-next 4/8] bridge: sysfs cleanup
Date: Fri, 20 Jun 2008 10:17:34 +0800
Message-ID: <485B133E.9080307@cn.fujitsu.com>
References: <485AFFF3.6070802@cn.fujitsu.com> <20080619181945.2b242e4d@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54691 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751393AbYFTCVb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 22:21:31 -0400
In-Reply-To: <20080619181945.2b242e4d@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger said the following on 2008-6-20 9:19:
> On Fri, 20 Jun 2008 08:55:15 +0800
> Wang Chen <wangchen@cn.fujitsu.com> wrote:
> 
>> When I am doing this series of patch, I notice that bridge's sysfs are
>> not cleanuped after failure and bridge delete.
>>
>> Here is the patch for it.
>>
>> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> 
> Let me look at this, I don't think it used to be a problem before the
> conversion from class_device to just device model.
> 

But, sysfs_create_link/file will leave some junk after failing.
Don't we care about that?

