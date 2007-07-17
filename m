From: vinay ravuri <vinaynyc@yahoo.com>
Subject: Socket Buffers and Memory Managment
Date: Tue, 17 Jul 2007 10:20:58 -0700 (PDT)
Message-ID: <551531.35231.qm@web82912.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82912.mail.mud.yahoo.com ([209.191.119.112]:24124 "HELO
	web82912.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755987AbXGQR1k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 13:27:40 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I am fairly new to linux socket buffers and have the
following questions!

I am working with a custom ethernet MAC that does not
allow me to specify a particular memory location for
the h/w to DMA the packet into (Rx side).  Instead, it
has a pool of fixed size buffers with some h/w
specific headers around each buffer that are managed
by h/w and will pick a free buffer and DMA the packet.
 It appears dev_alloc_skb() actually allocates the
physical memory and doesn't allow the user to specify
the skb.data to something specific to what I want
which is a problem for me.  First is my assumption
correct that I am cannot pick an arbitrary skb.data
location in struct sk_buff?  I want to avoid copying
the dma'ed data into a new socket buffer as it is
expense.  Is there any ways around this problem?

Also, if the h/w gives me a single packet in multiple
locations (i.e. non-contiguous chunks of memory), can
socket buffers handle chains of buffers?  I am looking
for a facility like mbuf's in netbsd where one can
chain multiple buffers together to make construct a
single packet.

Please e-mail me responses to vinay_nyc@yahoo.com

Thanks,
Vinay


 
____________________________________________________________________________________
Bored stiff? Loosen up... 
Download and play hundreds of games for free on Yahoo! Games.
http://games.yahoo.com/games/front
