From: "David S. Miller" <davem@redhat.com>
Subject: Re: RFC: per-socket statistics on received/dropped packets
Date: Thu, 06 Jun 2002 20:21:08 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020606.202108.52904668.davem@redhat.com>
References: <3CFFB9F8.54455B6E@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: cfriesen@nortelnetworks.com
In-Reply-To: <3CFFB9F8.54455B6E@nortelnetworks.com>
List-Id: netdev.vger.kernel.org


Your idea is totally useless for non-datagram sockets.
Only datagram sockets use the interfaces where you bump
the counters.

I don't like the patch, nor the idea behind it, at all.
