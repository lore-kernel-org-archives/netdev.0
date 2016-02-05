From: =?gb2312?B?1cXKpL7Z?= <zhangshengju@cmss.chinamobile.com>
Subject: Reply: [net] bonding: use return instead of goto
Date: Fri, 5 Feb 2016 09:42:24 +0800
Message-ID: <000301d15fb6$77bf08f0$673d1ad0$@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="gb2312"
Content-Transfer-Encoding: 7bit
Cc: <j.vosburgh@gmail.com>, <netdev@vger.kernel.org>
To: "'Jarod Wilson'" <jarod@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:9823 "EHLO
	cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823AbcBEBmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 20:42:18 -0500
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Wed, Feb 03, 2016 at 06:15:22AM +0000, Zhang Shengju wrote:
> > Replace 'goto' with 'return' to remove unnecessary check at label:
> > err_undo_flags.
> 
> I think you're going to have to explain how you came to the conclusion
that
> the check isn't necessary.
> 
> --
> Jarod Wilson
> jarod@redhat.com
Hi Jarod,

The reason is that 'err_undo_flags' do two things for the first slave
device:
1. revert bond mac address if it is set by the slave device.
2. revert bond device type if it's not ARPHRD_ETHER.

I think it's not necessary for the three places, they changed neither  bond
mac address nor type. 
it's straightforward to return directly.

Thanks,
Shengju
