From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3/3] powerpc: bpf: implement in-register swap for 64-bit
 endian operations
Date: Fri, 13 Jan 2017 17:17:26 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB02635FB@AcuExch.aculab.com>
References: <e73efe6facf6c06932b4a87707e5978172ee773e.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
 <bb264395301754f43b77ddec68a16dd34220abb4.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "ast@fb.com" <ast@fb.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "davem@davemloft.net" <davem@davemloft.net>
To: "'Naveen N. Rao'" <naveen.n.rao@linux.vnet.ibm.com>,
        "mpe@ellerman.id.au" <mpe@ellerman.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.189]:62776 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751220AbdAMRRv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 12:17:51 -0500
In-Reply-To: <bb264395301754f43b77ddec68a16dd34220abb4.1484326337.git.naveen.n.rao@linux.vnet.ibm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Naveen N. Rao
> Sent: 13 January 2017 17:10
> Generate instructions to perform the endian conversion using registers,
> rather than generating two memory accesses.
> 
> The "way easier and faster" comment was obviously for the author, not
> the processor.

That rather depends on whether the processor has a store to load forwarder
that will satisfy the read from the store buffer.
I don't know about ppc, but at least some x86 will do that.

	David
