From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] switch arcnet over to initcalls
Date: Wed, 21 May 2003 23:21:09 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030521.232109.26287528.davem@redhat.com>
References: <20030522075711.A11759@lst.de>
	<20030521.230211.15256464.davem@redhat.com>
	<20030522081002.A11850@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hch@lst.de
In-Reply-To: <20030522081002.A11850@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Christoph Hellwig <hch@lst.de>
   Date: Thu, 22 May 2003 08:10:03 +0200

   On Wed, May 21, 2003 at 11:02:11PM -0700, David S. Miller wrote:
   > com90xx init was being done via arcnet init.
   > Which in turn was being done in Space.c
   
   it was done in setup.c
   
Yuck, it's in pci_probes[]. :(

Ok, please resend your patch I'll apply it.
