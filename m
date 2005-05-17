From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 12:33:30 -0700
Message-ID: <428A470A.6010703@hp.com>
References: <Pine.LNX.4.61.0505170914130.29021@linux.site>	<20050517.104947.112621738.davem@davemloft.net>	<m1zmut7l5q.fsf@muc.de>	<428A3F86.1020000@us.ibm.com> <428A425F.7000807@hp.com> <428A452B.2010008@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <428A452B.2010008@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Actually, the problem is much worse now - we have virtual
> partitions in the Xen environment for instance where some
> packets are headed for local consumption (virtual network,
> no actual network latency to speak of) and some going
> out to the network. Having a global IP id generator just
> won't be able to keep up - we could wrap in submilliseconds...

and the classic TCP sequence number isn't _really_ all that far behind :)

>> The larger NFS UDP mount sizes mean more fragments, but intriguingly, 
>> they also mean slower wrap of the IP ID space :)
> 
> 
> True, but in a 32 NIC environment, see how they wrap ;)...

Yep - I'd thought that just about everyone had gone to per-dest or per-route IP 
ID's by now, but even then

rick
