From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Thu, 22 May 2003 18:01:52 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030522.180152.15252868.davem@redhat.com>
References: <20030522.015815.91322249.davem@redhat.com>
	<20030522.034058.71558626.davem@redhat.com>
	<1053602138.9475.34.camel@tux.rsn.bth.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: gandalf@wlug.westbo.se
In-Reply-To: <1053602138.9475.34.camel@tux.rsn.bth.se>
List-Id: netdev.vger.kernel.org

   From: Martin Josefsson <gandalf@wlug.westbo.se>
   Date: 22 May 2003 13:15:39 +0200

   On Thu, 2003-05-22 at 12:40, David S. Miller wrote:
   
   > +static unsigned long size_to_order(unsigned long size)
   
   Any reason you're not using get_order() ?

Actually, get_order() aparently only works on powers of
two, which 'size' is definitely not.
