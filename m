From: "David S. Miller" <davem@redhat.com>
Subject: Re: [patch] Convert sockets_in_use to use per_cpu areas
Date: Mon, 23 Dec 2002 16:23:51 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021223.162351.40761424.davem@redhat.com>
References: <20021223190847.G23413@in.ibm.com>
	<20021223.121632.105420794.davem@redhat.com>
	<20021224000048.GA14346@tapu.f00f.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kiran@in.ibm.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: cw@f00f.org
In-Reply-To: <20021224000048.GA14346@tapu.f00f.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Chris Wedgwood <cw@f00f.org>
   Date: Mon, 23 Dec 2002 16:00:48 -0800

   On Mon, Dec 23, 2002 at 12:16:32PM -0800, David S. Miller wrote:
   
   > You have to provide an explicit initializer for DEFINE_PER_CPU
   > declarations or you break some platforms with older GCC's which
   > otherwise won't put it into the proper section.
   
   I wonder if "some platforms with older GCC's" will ever have these
   issues resolved...

I still don't have gcc-3.2.1 working properly on sparc64.

I hope to have it working soon, but this does mean that 2.6.x
cannot deprecate it, whereas 2.7.x certainly can.
