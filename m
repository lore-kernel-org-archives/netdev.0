From: <Narendra_K@Dell.com>
Subject: RE: [PATCH] udev: create empty regular files to represent netinterfaces
Date: Thu, 29 Oct 2009 22:52:52 +0530
Message-ID: <EDA0A4495861324DA2618B4C45DCB3EE589663@blrx3m08.blr.amer.dell.com>
References: <20091016214024.GA10091@ldl.fc.hp.com> <20091022063619.GB6321@ldl.fc.hp.com> <20091027205551.GA31963@auslistsprd01.us.dell.com> <ac3eb2510910280123g3c0e3d95wb38a239238906027@mail.gmail.com> <20091029131125.GA13809@auslistsprd01.us.dell.com> <20091029142554.GA16869@kroah.com> <EDA0A4495861324DA2618B4C45DCB3EE589662@blrx3m08.blr.amer.dell.com> <20091029165259.GA9692@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <Matt_Domsch@Dell.com>, <kay.sievers@vrfy.org>, <dannf@hp.com>,
	<linux-hotplug@vger.kernel.org>, <netdev@vger.kernel.org>,
	<Jordan_Hargrave@Dell.com>, <Charles_Rose@Dell.com>,
	<bhutchings@solarflare.com>
To: <greg@kroah.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20091029165259.GA9692@kroah.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>Sure, it's never guaranteed by the kernel that this will 
>happen, especially as we speed up the boot process by doing 
>things async.

>So again, just fix your installer, or write a new udev rule 
>for your hardware platforms, or both.  But I still fail to see 
>why multiple names for network devices _in the kernel_ is a 
>solution for your issue.
>

The char device nodes solution does not propose having multiple names
for the network interfaces _in the kernel_. It is suggesting that we
have alternate names for kernel assigned names in user space and user
space utilities refer to the interface by these alternate names. The
userspace utilities would have to map the pathnames to kernel names
before issuing the ioctls. That way there is determinism without
embedding MAC or any other attribute. An Embedded_NIC_1 interface would
always refer to the Gb1 without having to depend on any attribute.

With regards,
Narendra K 

