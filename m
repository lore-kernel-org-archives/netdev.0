From: <Narendra_K@Dell.com>
Subject: RE: PATCH: Network Device Naming mechanism and policy
Date: Wed, 14 Oct 2009 00:23:02 +0530
Message-ID: <EDA0A4495861324DA2618B4C45DCB3EE589552@blrx3m08.blr.amer.dell.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com> <20091009210909.GA9836@auslistsprd01.us.dell.com> <20091009194401.036da080@nehalam> <20091010044056.GA5350@mock.linuxdev.us.dell.com> <20091010113219.3136fb8b@s6510>  <20091010210612.GA1927@kroah.com> <1255456950.2196.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <shemminger@vyatta.com>, <Matt_Domsch@Dell.com>,
	<netdev@vger.kernel.org>, <linux-hotplug@vger.kernel.org>,
	<Jordan_Hargrave@Dell.com>
To: <dcbw@redhat.com>, <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausxipps301.us.dell.com ([143.166.148.223]:14797 "EHLO
	ausxipps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760722AbZJMSyA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 14:54:00 -0400
Content-class: urn:content-classes:message
In-Reply-To: <1255456950.2196.18.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>If the BIOS support exists, it is trivial to use udev to 
>create the correct naming mechanism for your machine, either 
>using MAC address or BIOS-provided slot naming.  No kernel 
>patch is required.
>

Yes. In case, we want to rename only once. MAC address or slot names do
provide persistent naming. They help in retaining whatever names are
assigned during install time, which is the first instantiation of the
OS. But these names may not be as expected (like first on board network
interface name is expected to be "eth0" which is not always the case and
might not reflect what is written on the chassis label as "Gb1" and
"Gb2" etc) which would result in unattended installs break. Also image
based deployments will face problems by introducing state such as MAC
address. 

With regards,
Narendra K
