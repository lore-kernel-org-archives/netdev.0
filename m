From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Fri, 23 May 2003 01:22:05 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030523.012205.123984853.davem@redhat.com>
References: <1053602138.9475.34.camel@tux.rsn.bth.se>
	<20030522.180152.15252868.davem@redhat.com>
	<20030523102113.4fe38159.ak@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gandalf@wlug.westbo.se, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: ak@suse.de
In-Reply-To: <20030523102113.4fe38159.ak@suse.de>
List-Id: netdev.vger.kernel.org

   From: Andi Kleen <ak@suse.de>
   Date: Fri, 23 May 2003 10:21:13 +0200

   On Thu, 22 May 2003 18:01:52 -0700 (PDT)
   "David S. Miller" <davem@redhat.com> wrote:
   
   > Actually, get_order() aparently only works on powers of
   > two, which 'size' is definitely not.
   
   Are you sure? I always used it on all kinds of sizes.
   
   The algorithm looks for me like it works on any size. A quick test
   confirms that too.

I believe you.

Then what does that comment above it mean? :-)
