From: Veaceslav Falico <vfalico@redhat.com>
Subject: Re: [PATCH v4 net-next 01/12] bonding: remove bond->lock from
 bond_arp_rcv
Date: Tue, 18 Feb 2014 08:10:29 +0100
Message-ID: <20140218071029.GB14534@redhat.com>
References: <1392648088-21336-1-git-send-email-vfalico@redhat.com>
 <1392648088-21336-2-git-send-email-vfalico@redhat.com>
 <5302DB61.4070505@huawei.com>
 <20140218061222.GA18373@redhat.com>
 <530306C2.1050003@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Ding Tianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59975 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751020AbaBRHYd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Feb 2014 02:24:33 -0500
Content-Disposition: inline
In-Reply-To: <530306C2.1050003@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 18, 2014 at 03:07:46PM +0800, Ding Tianhong wrote:
>On 2014/2/18 14:12, Veaceslav Falico wrote:
>> On Tue, Feb 18, 2014 at 12:02:41PM +0800, Ding Tianhong wrote:
>>> On 2014/2/17 22:41, Veaceslav Falico wrote:
=2E..snip...
>>> I think it is not enough, you should add rcu_dereference for bond->=
curr_active_slave, it may be changed during
>>> the recv processing.
>>
>> bond->lock has absolutely nothing to du with bond->curr_active_slave=
 .
>>
>Yep, this problem is introduced by commit aeea64ac7=EF=BC=8C there is =
no way to protect the curr_active_slave, so
>I think you could fix it in this patch together.
>
>	else if (bond->curr_active_slave &&
>		 time_after(slave_last_rx(bond, bond->curr_active_slave),
>			    bond->curr_active_slave->jiffies))

It's not related to this patchset, but yeah, I'll send a fix afterwards=
=2E

>>>
>>> Regards
>>> Ding
>>>
>>>
>>
>>
>
>
