From: Chris Friesen <cfriesen@nortelnetworks.com>
Subject: Re: copybreak and gige network drivers
Date: Tue, 30 Sep 2003 10:39:11 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F79958F.7040103@nortelnetworks.com>
References: <Pine.LNX.4.44.0309291834330.2166-100000@training.scyld.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Donald Becker wrote:

> The decision point is pretty much break-even in the range of 150-400
> bytes, and most packets are either smaller or much larger, so just pick
> a likely value.  I tried to look at the bin sizes for the skbuff
> allocator, but you'll find that the overhead changes faster than you can
> possibly track.

Okay, will do.  Thanks for the excellent explanation.

Chris

-- 
Chris Friesen                    | MailStop: 043/33/F10
Nortel Networks                  | work: (613) 765-0557
3500 Carling Avenue              | fax:  (613) 765-2986
Nepean, ON K2H 8E9 Canada        | email: cfriesen@nortelnetworks.com
