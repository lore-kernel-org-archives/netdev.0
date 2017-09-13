From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: Convert int functions to bool
Date: Wed, 13 Sep 2017 15:55:50 -0700
Message-ID: <1505343350.8969.22.camel@perches.com>
References: <20170913223158.GA7860@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0175.hostedemail.com ([216.40.44.175]:56041 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751125AbdIMWzx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 18:55:53 -0400
In-Reply-To: <20170913223158.GA7860@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-09-14 at 01:31 +0300, Alexey Dobriyan wrote:
> > Global function ipv6_rcv_saddr_equal and static functions
> > ipv6_rcv_saddr_equal and ipv4_rcv_saddr_equal currently return int.
> > 
> > bool is slightly more descriptive for these functions so change
> > their return type from int to bool.
> 
> From code generation POV "int" is better for non-inlined functions
> especially on non-x86.

I don't agree with you here.  For instance:

$ size net/ipv4/*.o*
   text	   data	    bss	    dec	    hex	filename
   9832	     26	      0	   9858	   2682	net/ipv4/inet_connection_sock.o.arm.defconfig.new
   9860	     26	      0	   9886	   269e	net/ipv4/inet_connection_sock.o.arm.defconfig.old
