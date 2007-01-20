From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [patch 00/12] net namespace : L3 namespace - introduction
Date: Sat, 20 Jan 2007 12:42:45 +0100
Message-ID: <45B20035.6090609@fr.ibm.com>
References: <20070119154714.439706567@localhost.localdomain> <20070120044812.GA6123@MAIL.13thfloor.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:58354 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965259AbXATLnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jan 2007 06:43:20 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l0KBhJww104702
	for <netdev@vger.kernel.org>; Sat, 20 Jan 2007 11:43:19 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0KBhJjC1200326
	for <netdev@vger.kernel.org>; Sat, 20 Jan 2007 11:43:19 GMT
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0KBhIUX029221
	for <netdev@vger.kernel.org>; Sat, 20 Jan 2007 11:43:19 GMT
To: Herbert Poetzl <herbert@13thfloor.at>
In-Reply-To: <20070120044812.GA6123@MAIL.13thfloor.at>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Poetzl wrote:
> On Fri, Jan 19, 2007 at 04:47:14PM +0100, dlezcano@fr.ibm.com wrote:
>> This patchset provide a network isolation similar at what
>> Linux-Vserver provides. It is based on the L2 namespaces and relies on
>> the mechanisms provided by the namespace. This L3 namespaces does not
>> aim to bring full virtualization for the network, it provides an IP
>> isolation which can be reused for Linux-Vserver, jailed application or
>> application containers.
>>
>> A L3 namespace are always L2 s' childs and they can not create more
>> network namespaces, furthermore, they lose their NET_ADMIN
>> capability. They share their parent's network ressources. From the
>> parent namespace, IP addresses are created and assigned to the
>> different L3 childs. From this point, L3 namespaces can use their
>> assigned IP address and all computed broadcast addresses.
>   ~~~~~~~~~~~~~~~~~~~
> 
> okay, I conclude that this only handles a single address
> for now. what are your plans to handle entire sets?
> 
You can assign more than one IP address to a L3 network namespace.

