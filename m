From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] Prefix List patch against 2.5.70
Date: Mon, 02 Jun 2003 21:49:41 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030602.214941.102551312.davem@redhat.com>
References: <OF0DFD7FB1.3567B088-ON88256D39.00724E19@us.ibm.com>
	<Pine.LNX.4.44.0306030746420.8936-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, yoshfuji@linux-ipv6.org, krkumar@us.ibm.com,
	kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: pekkas@netcore.fi
In-Reply-To: <Pine.LNX.4.44.0306030746420.8936-100000@netcore.fi>
List-Id: netdev.vger.kernel.org

   From: Pekka Savola <pekkas@netcore.fi>
   Date: Tue, 3 Jun 2003 07:48:13 +0300 (EEST)
   
   Umm.. every prefix should have an interface route, so they're a required 
   subset of the routing table, correct?

That's entirely correct, thanks for noticing this :-)

This is why I said that they could add to a global list
all routes that meet this criteria.  Thus making any
querying mechanism simple to implement.
