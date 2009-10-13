From: <Narendra_K@Dell.com>
Subject: RE: PATCH: Network Device Naming mechanism and policy
Date: Tue, 13 Oct 2009 22:43:49 +0530
Message-ID: <EDA0A4495861324DA2618B4C45DCB3EE58954D@blrx3m08.blr.amer.dell.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com> <20091013150839.GD32107@ldl.fc.hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-hotplug@vger.kernel.org>,
	<Matt_Domsch@Dell.com>, <Jordan_Hargrave@Dell.com>,
	<Charles_Rose@Dell.com>
To: <dannf@hp.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20091013150839.GD32107@ldl.fc.hp.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>> These device nodes are not functional at the moment - open() returns 
>> -ENOSYS.  Their only purpose is to provide userspace with a kernel 
>> name to ifindex mapping, in a form that udev can easily manage.
>
>If the idea is just to provide a userspace-visible mapping 
>(and presumably take advantage of udev's infrastructure for 
>naming) does this need kernel changes? Could this be a 
>hierarchy under e.g. /etc/udev instead, using plain text 
>files? It still means we need something like libnetdevname for 
>apps to do the translation, but I'm not seeing why it matters 
>how this map is stored. Is there some special property of the 
>character devices (e.g. uevents) that we're not already 
>getting with the existing interfaces?

Yes. The char device by itself doesn't help in any way. But it provides
a flexible mechanism to provide multiple names for the same device, just
the way it is for disks.

With regards,
Narendra K
