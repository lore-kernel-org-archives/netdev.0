From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] switch sdla to initcalls
Date: Wed, 21 May 2003 01:34:53 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030521.013453.118618445.davem@redhat.com>
References: <20030521081938.GD22869@wotan.suse.de>
	<20030521102512.A30373@lst.de>
	<20030521082630.GF22869@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hch@lst.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ak@suse.de
In-Reply-To: <20030521082630.GF22869@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Andi Kleen <ak@suse.de>
   Date: Wed, 21 May 2003 10:26:30 +0200
   
   ISA probe order has nothing to do with namespaces or single
   cards. It works by reading values from specific registers and
   completely different devices can conflict.

Correct.

However, this sdla thing seems to want to be probed after
ethif_probe() runs.  And moving this to initcalls preserves
that relative relationship.

I have to admit that I must feign ignorance here.  And that someone
who really understands the EISA/ISA probe ordering requirements
should document them as best as possible in Space.c
