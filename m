From: "David S. Miller" <davem@redhat.com>
Subject: Re: System crash in tcp_fragment()
Date: Mon, 20 May 2002 15:08:33 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020520.150833.26960938.davem@redhat.com>
References: <3CE95190.75C52E2D@mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org, ak@muc.de,
   kuznet@ms2.inr.ac.ru, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: george@mvista.com
In-Reply-To: <3CE95190.75C52E2D@mvista.com>
List-Id: netdev.vger.kernel.org

   From: george anzinger <george@mvista.com>
   Date: Mon, 20 May 2002 12:42:08 -0700

   I wonder if you could help me squash a bug in the tcp code. 
   Here is what we know thus far:
   
   An SMP (x386 dual) 2.4.17 kernel crashes with an attempt to
   deference NULL at the end of tcp_fragment() (in
   net/ipv4/tcp_output.c) while attempting to link in the newly
   created fragment.  
   The bugzilla report is:

%99 of all such bug reports turn out to be driver bugs
where the net driver frees SKBs improperly or there is some
missing internal locking in the net device driver.

I think you efforts are better spent auditing what net
drivers are being used on this machine :-)
