From: "David S. Miller" <davem@redhat.com>
Subject: Re: bonding vs 802.3ad/Cisco EtherChannel link agregation
Date: Mon, 16 Sep 2002 12:55:55 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020916.125555.36549381.davem@redhat.com>
References: <20020913222213.69396.qmail@web14006.mail.yahoo.com>
	<3D85DB3D.DC65A80B@nortelnetworks.com>
	<3D860246.3060609@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cfriesen@nortelnetworks.com, cacophonix@yahoo.com,
   linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: greearb@candelatech.com
In-Reply-To: <3D860246.3060609@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Ben Greear <greearb@candelatech.com>
   Date: Mon, 16 Sep 2002 09:09:42 -0700
   
   NAPI helps my problem, but does not make it go away entirely.

There is a lot of logic in our TCP input btw that notices packet
reordering on the receive side and acts accordingly (ie. it does not
fire off fast retransmits or backoff prematurely when reordering
is detected)
