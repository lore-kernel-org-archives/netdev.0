From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch] netpoll: allow spaces in its parameter
Date: Wed, 17 Mar 2010 14:38:09 +0800
Message-ID: <4BA078D1.3090605@redhat.com>
References: <4BA07022.1040702@redhat.com>	<20100316.225950.222623826.davem@davemloft.net>	<4BA071BD.5040900@redhat.com> <20100316.231434.177653499.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15359 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753287Ab0CQGed (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Mar 2010 02:34:33 -0400
In-Reply-To: <20100316.231434.177653499.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Wed, 17 Mar 2010 14:07:57 +0800
> 
>> No, but silently accepting it as 0 is not correct, why don't
>> reject it if it is not allowed?
> 
> You have to be careful even with that.  For example, if two
> netconsoles are specified, seeing the space shouldn't
> kill the first netconsole specification we parsed.
> 
> A warning perhaps, but outright rejection of all specifications is
> really bad behavior.

OK, I will put a warning there instead.

Thanks, David!

