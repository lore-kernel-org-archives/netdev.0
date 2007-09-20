From: Nagendra Tomar <tomer_iisc@yahoo.com>
Subject: Re: [PATCH 2.6.23-rc6 Resending] NETWORKING : Edge Triggered EPOLLOUT events get missed for TCP sockets
Date: Thu, 20 Sep 2007 15:58:57 -0700 (PDT)
Message-ID: <798693.92196.qm@web53705.mail.re2.yahoo.com>
References: <Pine.LNX.4.64.0709201518540.8897@alien.or.mcafeemobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Davide Libenzi <davidel@xmailserver.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web53705.mail.re2.yahoo.com ([206.190.37.26]:46229 "HELO
	web53705.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751049AbXITW66 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 18:58:58 -0400
In-Reply-To: <Pine.LNX.4.64.0709201518540.8897@alien.or.mcafeemobile.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--- Davide Libenzi <davidel@xmailserver.org> wrote:


> That's not what POLLOUT means in the Unix meaning. POLLOUT indicates the 
> ability to write, and it is not meant as to signal every time a packet 
> (skb) is sent on the wire (and the buffer released).

Aren't they both the same ? Everytime an incoming ACK frees up a buffer
from the retransmit queue, the writability condition is freshly asserted,
much the same way as the readability condition is asserted everytime a 
new data is queued in the socket receive queue (irrespective of 
whether there was data already waiting to be read in the receive queue).

This difference in meaning of POLLOUT only arises in the ET case, which was
not what traditional Unix poll referred to. 

Since its a new game the rules can be modified (ofcourse based on the 
merits i.e. usability)

Thanx,
Tomar





      ___________________________________________________________ 
Want ideas for reducing your carbon footprint? Visit Yahoo! For Good  http://uk.promotions.yahoo.com/forgood/environment.html
