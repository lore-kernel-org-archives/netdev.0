From: "David S. Miller" <davem@redhat.com>
Subject: Re: purpose of the skb head pool
Date: Thu, 01 May 2003 02:35:28 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030501.023528.116383508.davem@redhat.com>
References: <20030429135506.A22411@lst.de>
	<16046.30879.738356.495523@robur.slu.se>
	<877k9bc5ox.fsf@deneb.enyo.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, hch@lst.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: fw@deneb.enyo.de
In-Reply-To: <877k9bc5ox.fsf@deneb.enyo.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Florian Weimer <fw@deneb.enyo.de>
   Date: Thu, 01 May 2003 12:38:38 +0200

   Robert Olsson <Robert.Olsson@data.slu.se> writes:
   
   >  Vanilla 2.5.66              381 kpps
   >  Magazine                    431 kpps
   >  Magazine + no skb_head_pool 435 kpps
   
   Can you rerun this test with random source/destination addresses, to
   get more realistic (for some configurations) numbers?
   
He can do this, but the issues we're trying to tackle first have
nothing to even do with what kind of routing cache accesses
are done.

It's all networking buffer overhead we're worried about at this
stage.
