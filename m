From: fernando@intellilink.co.jp
Subject: Re: [PATCH 2/2] TCP: Use 32768-65535 outgoing port range by
	default
Date: Tue,  3 Apr 2012 14:18:27 +0900
Message-ID: <20120403141827.sakagdugg04os8w8@webmail.int.intellilink.co.jp>
References: <20120403094840.ftxlwztl40gwcg4s@webmail.int.intellilink.co.jp>
	<20120403095018.rm7gil9xz0gsgccs@webmail.int.intellilink.co.jp>
	<20120403.005027.988304181797945160.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-2022-JP;
	format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "shemminger@vyatta.com" <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ils-mail01.intellilink.co.jp ([61.115.36.70]:60374 "EHLO
	ils-mail01.intellilink.co.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750756Ab2DCFSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 01:18:35 -0400
In-Reply-To: <20120403.005027.988304181797945160.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting David Miller <davem@davemloft.net>:
> From: fernando@intellilink.co.jp
> Date: Tue,  3 Apr 2012 09:50:18 +0900
>
>> There was a time when the ip masquerading code reserved the
>> 61000-65095 port range, which is the reason why the current default
>> upper limit in ip_local_port_range is 61000. However, the current
>> iptables-based masquerading and SNAT implementation does not have
>> that restriction; ipchains and the compatibilty mode that used the
>> range over 61000 exclusively is lone gone.
>
> I don't think so, anyone out there using "--to-port 61000-65095"
> or similar in their firewall setup will suddenly break with
> your change.

Yes, I considered that. The thing is that certain non-linux hosts 
already use a superset of the 61000-65095 range and 61000 looks like a 
magic number to most users. I just thought that anyone using --to-ports 
would set ip_local_port_range accordingly. Do you want me to document 
where 61000 comes from instead?
