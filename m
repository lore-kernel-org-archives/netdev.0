From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] remove sdla from setup.c
Date: Thu, 29 May 2003 02:57:49 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030529.025749.59658664.davem@redhat.com>
References: <20030528110658.GA26411@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hch@lst.de
In-Reply-To: <20030528110658.GA26411@lst.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Christoph Hellwig <hch@lst.de>
   Date: Wed, 28 May 2003 13:06:58 +0200

   sdla had calls from both Space.c and setup.c.  Leave the Space.c one
   alone as per previous discussion but move over the setup.c one to
   initcalls.  (and remove the prototype for a third one from setup.c!)
   
Looks ok, applied.

Some of this wan driver stuff is so crappy :(
