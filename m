From: "David S. Miller" <davem@redhat.com>
Subject: Re: [BK ChangeSet@1.1118.1.1] new module infrastructure for
 net_proto_family
Date: Wed, 23 Apr 2003 16:30:43 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030423.163043.41633133.davem@redhat.com>
References: <5.1.0.14.2.20030423114915.10840678@unixmail.qualcomm.com>
	<20030423192640.GD26052@conectiva.com.br>
	<5.1.0.14.2.20030423134636.100e5c60@unixmail.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@conectiva.com.br, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: maxk@qualcomm.com
In-Reply-To: <5.1.0.14.2.20030423134636.100e5c60@unixmail.qualcomm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Max Krasnyansky <maxk@qualcomm.com>
   Date: Wed, 23 Apr 2003 15:51:11 -0700

   >This is just the first part, DaveM already merged the second part,
   >that deals with struct sock 

   That's exactly what surprised me. He rejected complete patch and
   accepted something incomplete and broken.

No, it was not broken, because he told me completely where he
was going with his changes.  He was building infrastructure piece by
piece, and that's always an acceptable way to do things as long
as it is explained where one is going with the changes.

Your stuff was unacceptable from the start because you didn't put
the ->owner into the protocol ops.
   
   I thought changes like that are always discussed on the lkml.

No, networking patches can go solely to netdev or linux-net.
   
