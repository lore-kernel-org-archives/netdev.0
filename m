From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [Patch net] mlx4: set csum_complete_sw bit when fixing complete csum
Date: Tue, 28 Jun 2016 17:30:31 +0300
Message-ID: <CAJ3xEMhgyvq2_ZsipQ_iFcC6Ef65hj2rkZ0U5scGvj4-=eNkLA@mail.gmail.com>
References: <1467051724-8314-1-git-send-email-xiyou.wangcong@gmail.com>
 <CAJ3xEMjgb6K1QeWZKNLWJWk4Ch++FmcV-PPWp7VJzWLYSHo8YQ@mail.gmail.com> <CAM_iQpUBQqV3oC7=WqyNtu58HmbJbV29yz6_r_ib6XqWpw7VGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Shani Michaeli <shanim@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Yishai Hadas <yishaih@mellanox.com>,
	Carol L Soto <clsoto@us.ibm.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f52.google.com ([209.85.218.52]:35388 "EHLO
	mail-oi0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999AbcF1Oag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 10:30:36 -0400
Received: by mail-oi0-f52.google.com with SMTP id r2so25015703oih.2
        for <netdev@vger.kernel.org>; Tue, 28 Jun 2016 07:30:32 -0700 (PDT)
In-Reply-To: <CAM_iQpUBQqV3oC7=WqyNtu58HmbJbV29yz6_r_ib6XqWpw7VGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 28, 2016 at 12:44 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Mon, Jun 27, 2016 at 2:08 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
>> On Mon, Jun 27, 2016 at 9:22 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:

>> can you point/paste the exact warning and how to reproduce that? is
>> that as simple as running ping and/or ping6?

> Yes, ping is enough to reproduce it every time.

> The warning is below:
> [ 8693.680997] eth0: hw csum failure

Wow, can you please report us the exact card type (lspci -nn | grep -i
mellanox) and  firmware version (ethtool -i $DEV)
