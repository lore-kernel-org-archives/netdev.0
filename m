From: "David S. Miller" <davem@redhat.com>
Subject: Re: Network oops
Date: Mon, 10 Jun 2002 01:31:10 -0700 (PDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <ae1oha$jd2$2@main.gmane.org>
References: <3D0390E2.1B80ADEE@mvista.com>
	<20020609.213224.01016187.davem@redhat.com>
	<3D045F15.578E1DA9@mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, linux-net@vger.kernel.org,
   ak@muc.de, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: george@mvista.com
In-Reply-To: <3D045F15.578E1DA9@mvista.com>
List-Id: netdev.vger.kernel.org

   From: george anzinger <george@mvista.com>
   Date: Mon, 10 Jun 2002 01:11:01 -0700

   "David S. Miller" wrote:
   > 
   > Also we need to know what network driver, if preemption is being
   > used (being from mvista I assume you are using preemption, and if
   > so make sure you have the preemption networking patches applied).
   
   Uh, are you saying there is a set of network patches?  If
   so, where might they be found?  And yes, we are testing
   preemption, trying to wring out the "last" bug :)  (Could
   you be referring to the patches we are developing?)
   
An mvista person recently put "make net preempt safe" patches
into 2.5.x  Basically it amounted to putting a few preempt_disable
sections into net/core/skbuff.c
