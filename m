From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Networking: send-to-self [link to non-broken patch
 this time]
Date: Wed, 18 Sep 2002 19:01:17 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020918.190117.53168129.davem@redhat.com>
References: <3D890A51.7000103@candelatech.com>
	<20020918.182855.47438220.davem@redhat.com>
	<3D893165.10106@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: greearb@candelatech.com
In-Reply-To: <3D893165.10106@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Ben Greear <greearb@candelatech.com>
   Date: Wed, 18 Sep 2002 19:07:33 -0700

   David S. Miller wrote:
   
   > I mean put the ifdefs in a header file such as tcp.h, not in the *.c
   > code.
   
   Would you object to me just removing all of them and having the patch
   unconditionally compiled in?

Your comments say that SIOCBINDTODEVICE behavior is changed, how can
we legitimately do that all the time without breaking apps?
