From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bugme-new] [Bug 9174] New: linux-2.6.23-git11 kernel panic
Date: Thu, 18 Oct 2007 11:53:20 +0200
Message-ID: <47172D10.2040309@trash.net>
References: <bug-9174-10286@http.bugzilla.kernel.org/> <20071017130131.365f9fb6.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: plamen.petrov@tk.ru.acad.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33015 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755387AbXJRJxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 05:53:44 -0400
In-Reply-To: <20071017130131.365f9fb6.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Wed, 17 Oct 2007 07:36:16 -0700 (PDT)
> bugme-daemon@bugzilla.kernel.org wrote:
> 
>> http://bugzilla.kernel.org/show_bug.cgi?id=9174
>>
>>            Summary: linux-2.6.23-git11 kernel panic
 >>

>> EIP is at packet_rcv_0x1a2/0x360


Please find out on which device the packet socket is opened by
looking at /proc/net/packet and comparing the Iface shown there
to the ifindexes listed in "ip link list".
