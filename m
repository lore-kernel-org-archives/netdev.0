From: Nivedita Singhvi <niv@us.ibm.com>
Subject: Re: [BK PATCH] 2.6.2 SCTP updates
Date: Mon, 09 Feb 2004 12:50:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4027F28A.40704@us.ibm.com>
References: <Pine.LNX.4.58.0402061649001.10831@localhost.localdomain>	<20040206194518.56787717.davem@redhat.com>	<Pine.LNX.4.58.0402091155070.10043@localhost.localdomain>	<4027EECA.9000705@us.ibm.com> <20040209124145.48de8d55.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040209124145.48de8d55.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:

> I understand.
> 
> But there was no known reason to tweak things for SCTP.

Yeah, I agree it doesn't matter right now for SCTP.
I don't know of anyone running SCTP *and* heavy NFS/raw
apps simultaneously. But they open up those socket
buffers for some real decent SCTP performance and
watch that unconstrained raw or udp traffic bludgeon
any congestion controlled streams like TCP and SCTP
out of the network. But this is a rather intrinsic
problem with other solutions, really..

thanks,
Nivedita
