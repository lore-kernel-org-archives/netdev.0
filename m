From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Networking: send-to-self [link to non-broken patch
 this time]
Date: Wed, 18 Sep 2002 15:55:34 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020918.155534.102954410.davem@redhat.com>
References: <3D88217A.6070702@candelatech.com>
	<3D8826BE.5090007@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: greearb@candelatech.com
In-Reply-To: <3D8826BE.5090007@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Ben Greear <greearb@candelatech.com>
   Date: Wed, 18 Sep 2002 00:09:50 -0700
   
   http://www.candelatech.com/sts_2.4.19.patch

I don't think I'll be applying this:

1) No tcp ipv6 bits
2) SIOC{S,G}ACCEPTLOCALADDRS added, but no 32-bit translation
   code added to varions 64-bit/32-bit biarch port ioctl handling.
   Also, no code added to the ioctl dispatch in the networking
   so that devices could actually receive these requests.
3) Finally, it's just too damn ugly.  If you have to ifdef it then
   it really doesn't belong in the tree.  Maybe if the device number
   comparison logic changes existed via macros in tcp.h and thus
   removing all the CONFIG_NET_SENDTOSELF ifdefs from tcp*.c code
   it might be more palatable.
4) I haven't reviewed the ramifications of the route lookup changes,
   that is Alexey's territory.

Sorry, these changes are pretty ugly right now.
