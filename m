From: <Narendra_K@Dell.com>
Subject: RE: PATCH: Network Device Naming mechanism and policy
Date: Mon, 9 Nov 2009 20:11:47 +0530
Message-ID: <EDA0A4495861324DA2618B4C45DCB3EE589727@blrx3m08.blr.amer.dell.com>
References: <20091016003245.GD29672@ldl.fc.hp.com> <EDA0A4495861324DA2618B4C45DCB3EE589579@blrx3m08.blr.amer.dell.com> <20091016152053.GA9862@ldl.fc.hp.com> <1255707193.2869.12.camel@achroite> <20091016214024.GA10091@ldl.fc.hp.com> <EDA0A4495861324DA2618B4C45DCB3EE5895AF@blrx3m08.blr.amer.dell.com> <4ADC906E.2050909@kadzban.is-a-geek.net> <EDA0A4495861324DA2618B4C45DCB3EE5896D2@blrx3m08.blr.amer.dell.com> <20091106084921.GA16700@bongo.bofh.it> <20091106220637.GB15533@mock.linuxdev.us.dell.com> <20091106223524.GA27121@bongo.bofh.it>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <bryan@kadzban.is-a-geek.net>, <dannf@hp.com>,
	<bhutchings@solarflare.com>, <netdev@vger.kernel.org>,
	<linux-hotplug@vger.kernel.org>, <Jordan_Hargrave@Dell.com>,
	<Charles_Rose@Dell.com>, <Sandeep_K_Shandilya@Dell.com>
To: <md@Linux.IT>, <Matt_Domsch@Dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:3895 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753220AbZKIOmT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 09:42:19 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20091106223524.GA27121@bongo.bofh.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>> > As a distribution developer I highly value solutions like 
>this which 
>> > do not require patching every application which deals with 
>interface 
>> > names and then teaching users about aliases which only 
>work in some 
>> > places and are unknown to the kernel.
>> Fair enough - but would you object if we changed the naming scheme 
>> from eth%d to something else?
>I suppose that this would depend on what else. :-) Since you 
>want radical changes I recommend that you design the new 
>persistent naming infrastructure in a way that will allow root 
>to choose to use the classic naming scheme, or many users will 
>scream a lot and at least some distributions will do it anyway.
>I also expect that providing choice at the beginning of 
>development may lead to more acceptance later if and when the 
>new scheme will have proved itself to be superior (at least in 
>some situations).
>You have tought about this for a long time and if so far you 
>have not found a solution which is widely considered superior 
>then I doubt that one will appear soon. Providing your 
>favourite naming scheme as an optional add on will immediately 
>benefit those who like it and greatly reduce opposition from 
>those who do not.

In that way, I suppose char device node solution fits the scheme
perfectly. It doesn't change or interfere with the kernel's default
naming scheme (ethN) in any way. Also, the applications continue to work
the way they did and in addition to supporting traditional names, they
would also support pathnames. Whether all the user space applications
need to be patched can be discussed and debated. But, we can patch
applications like, installers and firewall code, which when don't see
determinism ("eth0 mapping to integrated port 1"), fail and cause very
high impact could be patched. Since users are already familiar with
pathnames like /dev/disk/by-id{label, uuid}, I suppose it might not be
very difficult to get used to pathnames like
/dev/netdev/by-chassis-label/Embedded_NIC_1. Would that be acceptable ?


With regards,
Narendra K  
