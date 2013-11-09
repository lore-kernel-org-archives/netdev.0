From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH net-next v2 9/10] bonding: remvoe unwanted lock for bond
 enslave and release
Date: Sat, 09 Nov 2013 22:15:30 +0800
Message-ID: <527E4382.4000400@gmail.com>
References: <527C4793.5060306@huawei.com> <527D1C47.4040008@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:38509 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111Ab3KIO0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Nov 2013 09:26:12 -0500
Received: by mail-pa0-f54.google.com with SMTP id lj1so464897pab.27
        for <netdev@vger.kernel.org>; Sat, 09 Nov 2013 06:26:11 -0800 (PST)
In-Reply-To: <527D1C47.4040008@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013/11/9 1:15, Nikolay Aleksandrov =E5=86=99=E9=81=93:
> On 11/08/2013 03:08 AM, Ding Tianhong wrote:
>> The bond_change_active_slave() and bond_select_active_slave()
>> do't need bond lock anymore, so remove the unwanted bond lock
>> for these two functions.
>>
>> The bond_select_active_slave() will release and acquire
>> curr_slave_lock, so the curr_slave_lock need to protect
>> the function.
>>
>> In bond enslave and bond release, the bond slave list is also
>> protected by RTNL, so bond lock is no need to exist, remove
>> the lock and clean the functions.
>>
>> Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
>> Suggested-by: Veaceslav Falico <vfalico@redhat.com>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
> Small nitpick about the subject:
> "remvoe" -> "remove"
:-)

>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
