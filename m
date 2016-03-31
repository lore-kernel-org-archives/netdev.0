From: =?gb2312?B?1cXKpL7Z?= <zhangshengju@cmss.chinamobile.com>
Subject: Re: [net-next] bond: output message before setting slave to inactive
Date: Thu, 31 Mar 2016 09:23:01 +0800
Message-ID: <000401d18aeb$de199060$9a4cb120$@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: 7bit
Cc: <j.vosburgh@gmail.com>, <vfalico@gmail.com>,
	<gospo@cumulusnetworks.com>, <netdev@vger.kernel.org>
To: "'David Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:5855 "EHLO
	cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754213AbcCaBXb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Mar 2016 21:23:31 -0400
Content-Language: en-us
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> Date: Tue, 29 Mar 2016 06:32:57 +0000
> 
> > This patch moves output message before setting slave to inactive, this
> > will print the correct status of slave device.
> >
> > Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
> 
> I think the message is in the appropriate spot wrt. state, so I will not
apply
> this, thanks.

The message will always print 'backup',  since the code set it to inactive
before this output.
I think this will cause a little confused, because even when I detach an
active slave, the output is always 'backup'.

Thanks.
