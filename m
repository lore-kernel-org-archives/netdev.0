From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] fix HIPQUAD macro in kernel.h
Date: Thu, 08 Aug 2002 07:48:53 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020808.074853.114346036.davem@redhat.com>
References: <20020808133112.E11828@sunbeam.de.gnumonks.org>
	<20020808134113.A2552@wotan.suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: laforge@gnumonks.org, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <owner-netdev@oss.sgi.com>
To: ak@suse.de
In-Reply-To: <20020808134113.A2552@wotan.suse.de>
List-Id: netdev.vger.kernel.org

   From: Andi Kleen <ak@suse.de>
   Date: Thu, 8 Aug 2002 13:41:13 +0200
   
   That change is wrong. IP address should be always in network order
   (=BE) while in kernel.

He's fixing the HIPQUAD ('H' as in 'host') not NIPQUAD ('N' as in
'network') macro.

If you disagree with people using HIPQUAD at all, recommend that
it be deleted.  Until then, it ought to be fixed :-)
