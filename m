From: Harry Edmon <harry@atmos.washington.edu>
Subject: Re: Network performance degradation from 2.6.11.12 to 2.6.16.20
Date: Mon, 19 Jun 2006 06:54:46 -0700
Message-ID: <4496ACA6.7090305@atmos.washington.edu>
References: <4492D5D3.4000303@atmos.washington.edu>	<20060617153511.53a129a3.akpm@osdl.org>	<44948EF6.1060201@atmos.washington.edu> <20060617165611.2c478723.akpm@osdl.org> <4494C592.6090601@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dew1.atmos.washington.edu ([128.95.89.41]:21717 "EHLO
	dew1.atmos.washington.edu") by vger.kernel.org with ESMTP
	id S932211AbWFSNy7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jun 2006 09:54:59 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <4494C592.6090601@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:

> Does this fix it?
>    # sysctl -w net.ipv4.tcp_abc=0

That did not help.  I have 1 minute outputs from tcpdump under both 2.6.11.12 
and 2.6.16.20.  You will see a large size difference between the files.  Since 
the 2.6.11.12 one is 2 MBytes, I thought I would post them via the web instead 
of via attachments.   Look at:

http://www.atmos.washington.edu/~harry/linux/2.6.11.12.out.1min
http://www.atmos.washington.edu/~harry/linux/2.6.16.20.out.1min

And again, thank to all of you for looking into this.

-- 
  Dr. Harry Edmon			E-MAIL: harry@atmos.washington.edu
  206-543-0547				harry@u.washington.edu
  Dept of Atmospheric Sciences		FAX:	206-543-0308
  University of Washington, Box 351640, Seattle, WA 98195-1640
