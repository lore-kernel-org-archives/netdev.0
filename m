From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Thu, 22 May 2003 17:59:38 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030522.175938.38697866.davem@redhat.com>
References: <20030522.015815.91322249.davem@redhat.com>
	<20030522.034058.71558626.davem@redhat.com>
	<20030522114438.GD2961@netnation.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org, kuznet@ms2.inr.ac.ru
Return-path: <linux-net-owner@vger.kernel.org>
To: sim@netnation.com
In-Reply-To: <20030522114438.GD2961@netnation.com>
List-Id: netdev.vger.kernel.org

   From: Simon Kirby <sim@netnation.com>
   Date: Thu, 22 May 2003 04:44:38 -0700
   
   There's no APIC on this test box, so it's using the XT-PIC.
   Production has an APIC, so I assume the overhead would be less
   there.

It is absolutely critical for routing throughput.  XT-PIC overhead
severely limits your maximum packets/second switching rate.

Another thing to watch out for are drivers still using PIO to
access device registers (3c59x comes to mind).
