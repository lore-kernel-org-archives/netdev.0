From: "David S. Miller" <davem@redhat.com>
Subject: Re: RFC: per-socket statistics on received/dropped packets
Date: Sat, 08 Jun 2002 16:04:07 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <adu3a4$l7d$2@main.gmane.org>
References: <20020606.202108.52904668.davem@redhat.com>
	<3D01307C.4090503@candelatech.com>
	<20020608170511.B26821@mark.mielke.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, cfriesen@nortelnetworks.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: mark@mark.mielke.cc
In-Reply-To: <20020608170511.B26821@mark.mielke.cc>
List-Id: netdev.vger.kernel.org


You guys we have SNMP statistics for these events, there
is no reason to have them per-socket.  You cannot convince
me that when you are diagnosing a problem the SNMP stats
are not enough to show you if the packets are being dropped.

If not, this means we need to add more SNMP events, that is
all it means.
