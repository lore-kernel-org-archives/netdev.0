From: "Alex Aizman" <itn780@yahoo.com>
Subject: RE: [Ksummit-2005-discuss] Summary of 2005 Kernel Summit Proposed Topics
Date: Wed, 30 Mar 2005 11:28:07 -0800
Message-ID: <200503301928.j2UJSTbM024992@oss.sgi.com>
References: <20050330161522.GH32111@g5.random>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'jamal'" <hadi@cyberus.ca>, "'Dmitry Yusupov'" <dmitry_yus@yahoo.com>,
        "'James Bottomley'" <James.Bottomley@HansenPartnership.com>,
        "'Rik van Riel'" <riel@redhat.com>, <mpm@selenic.com>,
        <michaelc@cs.wisc.edu>, <ksummit-2005-discuss@thunk.org>,
        "'netdev'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <open-iscsi@googlegroups.com>, "'Andi Kleen'" <ak@muc.de>
In-Reply-To: <20050330161522.GH32111@g5.random>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Andrea Arcangeli wrote: 
> 
> All I care about is to assign a mempool ID to the skb (ID 
> being unique identifier for the tcp connection I don't care 
> how the implementation is). 

It makes sense to provide an API for the NIC driver to allocate skb from the
*right* mempool. This way if I have plenty of hw rings and/or can allow
myself a luxury to associate 1-to-1 connection and ring, there's a nice and
clean memory management model. Even NICs that have only few rings could use
this - for critical (e.g., storage) connections. 

Alex
