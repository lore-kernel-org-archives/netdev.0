From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: SIOCADDMULTI for unicast broken
Date: Sat, 04 Jan 2003 02:32:54 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E168E26.1030006@pobox.com>
References: <Pine.LNX.4.44.0301032100340.29812-100000@beohost.scyld.com> <20030103224852.L48869@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Donald Becker <becker@scyld.com>, Ben Greear <greearb@candelatech.com>,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <20030103224852.L48869@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I wonder if there are any good uses for more advanced RX filtering that 
is beginning to appear.  I could certainly imagine an interface that was 
a more generic RX filtering interface, and [just by accident] happened 
to support existing unicast and multicast rx-mode-related controls.

As vendors stuff features onto cards and try to figure out where is the 
best dividing line between TCP stack acceleration and TCP stack offload, 
it seems to me that recent cards more often than not have nice RX 
filtering capabilities.  If you look at the world through GigE-colored 
glasses, the RX filtering picture gets even better.  There are some fun 
SMP implications with flexible enough RX filtering, for example.
