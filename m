From: "David S. Miller" <davem@redhat.com>
Subject: Re: System crash in tcp_fragment()
Date: Tue, 21 May 2002 00:22:49 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <acctgo$gfl$2@main.gmane.org>
References: <3CE9E466.AC2358EE@mvista.com>
	<20020520.230021.29510217.davem@redhat.com>
	<3CE9F679.90ACF597@mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: niv@us.ibm.com, kuznet@ms2.inr.ac.ru, ak@suse.de, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, ak@muc.de, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: george@mvista.com
In-Reply-To: <3CE9F679.90ACF597@mvista.com>
List-Id: netdev.vger.kernel.org

   From: george anzinger <george@mvista.com>
   Date: Tue, 21 May 2002 00:25:46 -0700
   
   I understand the issue.  The question is what is the
   result.  Bogus numbers do.. what?  Does the kernel crash or
   does the user think strange things while every thing just
   keeps on working?

It's a quality of implementation issue.

It is just one example of a place where we use these kinds
of assumptions to index tables and the like.
