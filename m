From: Thomas Graf <tgraf@suug.ch>
Subject: Re: receive only one record from the routing table
Date: Fri, 17 Jun 2005 21:13:40 +0200
Message-ID: <20050617191340.GO22463@postel.suug.ch>
References: <Pine.LNX.4.61.0506171359490.31631@localhost.localdomain> <20050617141527.GN22463@postel.suug.ch> <Pine.LNX.4.61.0506172057240.26739@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: =?iso-8859-1?B?VG9t4T8=?= Macek <maca02@atlas.cz>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0506172057240.26739@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Tom?? Macek <Pine.LNX.4.61.0506172057240.26739@localhost.localdomain> 2005-06-17 20:57
> Part of my routing table is here:
> 
> 3.3.0.0         *               255.255.0.0     U     0      0        0 eth1
> default         meric           0.0.0.0         UG    0      0        0 eth0
> 
> Ommiting NLM_F_DUMP and typing './a.out 3.3.0.0' gives
> 
> Error in recieved packet: Success
> Read From Socket Failed...

Bcause you don't set rtm_dst_len to the prefix length or 32,
and rtm_family (AF_INET). You could also use libnl, probably
easier to use.
