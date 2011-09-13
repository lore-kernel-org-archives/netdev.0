From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 2/2] qlcnic: Change CDRP function
Date: Tue, 13 Sep 2011 11:22:50 -0700
Message-ID: <1315938171.25776.11.camel@Joe-Laptop>
References: <1315937179-22383-1-git-send-email-anirban.chakraborty@qlogic.com>
	 <1315937179-22383-2-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:60195 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755856Ab1IMSWv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Sep 2011 14:22:51 -0400
In-Reply-To: <1315937179-22383-2-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-09-13 at 11:06 -0700, Anirban Chakraborty wrote:
> Argument list to CDRP function has become unmanageably long. Fix it by properly
> declaring a struct that encompasses all the input and output parameters.

I don't think this is better.

I think you've overloaded the issue_cmd function and should
use separate issue_cmd_<type> functions instead.
