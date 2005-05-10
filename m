From: Rick Jones <rick.jones2@hp.com>
Subject: Re: tg3 support broken on PPC, a workaround
Date: Tue, 10 May 2005 15:13:25 -0700
Message-ID: <42813205.1040709@hp.com>
References: <20050510113308.kbjo3ob1ck0404k8@158.49.151.11>	<1115743966.8570.26.camel@rh4> <20050510.121214.39158393.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Grant Grundler <iod00d@hp.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20050510.121214.39158393.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> We really should be disconnecting at single cacheline boundaries
> on RISC systems.  The PCI controllers on RISC machines are
> going to disconnect the tg3 when it crosses a cache line
> boundary, so all these setting do is waste PCI bandwidth.

It is my understanding that PA-RISC and IA64 controllers behave differently. 
For confirmation one way or the other, I've cc'd someone who could talk about it 
much more cogently than I.

rick jones
