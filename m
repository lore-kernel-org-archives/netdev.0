From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH V2 09/12] net/eipoib: Add main driver functionality
Date: Sun, 5 Aug 2012 00:33:08 +0300
Message-ID: <CAJZOPZJRGMNGHP6XZx-4t998bHs+uD28Yxhjoy5VMUTFmkHZGQ@mail.gmail.com>
References: <1343840975-3252-10-git-send-email-ogerlitz@mellanox.com>
	<87boitz044.fsf@xmission.com>
	<501C3527.6060809@mellanox.com>
	<20120803.143315.151094375569109262.davem@davemloft.net>
	<501C5328.4060301@mellanox.com>
	<501C669B.2030303@mellanox.com>
	<1d3bddff-4b3a-4ed1-b8f9-21bd531ba20b@email.android.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ali Ayoub <ali@mellanox.com>, David Miller <davem@davemloft.net>,
	ogerlitz@mellanox.com, roland@kernel.org, netdev@vger.kernel.org,
	sean.hefty@intel.com, erezsh@mellanox.co.il
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:65522 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753930Ab2HDVdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Aug 2012 17:33:09 -0400
Received: by yenl2 with SMTP id l2so1750632yen.19
        for <netdev@vger.kernel.org>; Sat, 04 Aug 2012 14:33:09 -0700 (PDT)
In-Reply-To: <1d3bddff-4b3a-4ed1-b8f9-21bd531ba20b@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 4, 2012 at 4:34 AM, Eric W. Biederman <ebiederm@xmission.com> wrote:
> Ali Ayoub <ali@mellanox.com> wrote:

>>With this driver, existing VMs, and their existing IP applications, can
>>run as-is on InfiniBand network.

> Actually it doesn't work like that.
> If my application really needs ethernet it will not work with your driver.

Eric,

Starting to address your email

If your application really needs Ethernet, it will not work with
IPoIB, since the latter only supports IP apps. So this isn't the
problem we're trying to solve here, but rather allow IP app running in
PV mode to use IPoIB.

> I can not run decnet or appletalk or ATAoE or PPPoE or LACP

[...]

> or use VLANs

YES you can, vlan devices can be set over eipoib devices, and the
eipoib driver maps the vlan ID to IB Partition using a mapping defined
by the admin.

> or any of a thousand other things that require real live ethernet to function.
[...]
> Similarly eIPoIB does not make sense from a performance standpoint because
> the best performance requires the applications and hypervisors are infiniband
> and teaching the apps to cope.

agree 100% re the "best performance" part of this sentence, if your
app looks for best perf, yes you can use IB in either native or SRIOV
mode, as I mentioned in my response to Dave.

Or.

Or.
