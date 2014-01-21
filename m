From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v2 2/2] bonding: add netlink attributes to slave
 link dev
Date: Tue, 21 Jan 2014 23:00:16 +0100
Message-ID: <20140121220016.GF3015@minipsycho.orion>
References: <20140117065756.3194.70179.stgit@monster-03.cumulusnetworks.com>
 <20140121133426.GC3015@minipsycho.orion>
 <0A99CC69-DBFF-46DF-9300-D2C6DF10A965@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Ding Tianhong <dingtianhong@huawei.com>
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:47750 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754567AbaAUWAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 17:00:21 -0500
Received: by mail-ee0-f51.google.com with SMTP id b57so4391369eek.24
        for <netdev@vger.kernel.org>; Tue, 21 Jan 2014 14:00:20 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <0A99CC69-DBFF-46DF-9300-D2C6DF10A965@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Jan 21, 2014 at 10:36:58PM CET, sfeldma@cumulusnetworks.com wrote:
>
>On Jan 21, 2014, at 5:34 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>
>>> +	if (rtnl_bond_slave_fill(skb, dev))
>>> +		goto nla_put_failure;
>>> +
>>=20
>> I must say I do not like this at all. This should be done in a gener=
ic
>> way. By a callback registered by bonding and possibly other master-s=
lave
>> device types.
>
>The bond was registered with the ndo_get_slave op.  ndo_get_slave coul=
d be used for other master-slave device types.  I=E2=80=99ll agree that=
 rtnl_bond_slave_fill() could have been written more generically.  Is t=
hat the objection?

I think is should be done rather in rtnl_link_ops. It's the natural poi=
nt
for this ops. I have patchset prepared. Will send it very soon.

>
>> I have something in mind, will try to prepare patch soon.
>
>
