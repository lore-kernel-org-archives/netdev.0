From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 2/2] bonding: add netlink attributes to slave link dev
Date: Tue, 21 Jan 2014 13:36:58 -0800
Message-ID: <0A99CC69-DBFF-46DF-9300-D2C6DF10A965@cumulusnetworks.com>
References: <20140117065756.3194.70179.stgit@monster-03.cumulusnetworks.com> <20140121133426.GC3015@minipsycho.orion>
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Netdev <netdev@vger.kernel.org>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Ding Tianhong <dingtianhong@huawei.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:43794 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753055AbaAUVhF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 16:37:05 -0500
In-Reply-To: <20140121133426.GC3015@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jan 21, 2014, at 5:34 AM, Jiri Pirko <jiri@resnulli.us> wrote:

>> +	if (rtnl_bond_slave_fill(skb, dev))
>> +		goto nla_put_failure;
>> +
>=20
> I must say I do not like this at all. This should be done in a generi=
c
> way. By a callback registered by bonding and possibly other master-sl=
ave
> device types.

The bond was registered with the ndo_get_slave op.  ndo_get_slave could=
 be used for other master-slave device types.  I=92ll agree that rtnl_b=
ond_slave_fill() could have been written more generically.  Is that the=
 objection?

> I have something in mind, will try to prepare patch soon.
