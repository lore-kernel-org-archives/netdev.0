From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] new net device feature: shared-ipv6-cards
Date: Wed, 21 Aug 2002 14:55:09 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020821.145509.22238146.davem@redhat.com>
References: <OF55880994.F5346670-ONC1256C1C.005D4FB1@de.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, owner-netdev@oss.sgi.com,
   pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: AHERRMAN@de.ibm.com
In-Reply-To: <OF55880994.F5346670-ONC1256C1C.005D4FB1@de.ibm.com>
List-Id: netdev.vger.kernel.org

   From: "Andreas Herrmann" <AHERRMAN@de.ibm.com>
   Date: Wed, 21 Aug 2002 19:00:39 +0200

     > In this way we are guaranteed not to have problems of this kind
     > in future.
   
   What about implementing your alternative proposal in 2.5 and to use
   the current approach in a next 2.4.x kernel?

Just because you have some code depending upon this doesn't
mean that is the way we should implement it in 2.4.x

We should do it right from the start.  Because doing it properly
hurts no other driver except for yours. :-)
