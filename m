From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [RFT] sky2 vs iptables
Date: Wed, 04 Oct 2006 10:11:15 -0400
Message-ID: <4523C103.1090000@gentoo.org>
References: <44FE2618.3010705@gentoo.org>	<20060906141651.116aa758@localhost.localdomain>	<450CBA9A.4040705@gentoo.org> <20060921163737.027b7701@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcclung@nebrwesleyan.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp161.iad.emailsrvr.com ([207.97.245.161]:13799 "EHLO
	smtp161.iad.emailsrvr.com") by vger.kernel.org with ESMTP
	id S1161007AbWJDOLM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 10:11:12 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060921163737.027b7701@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> I tried the script with 2.6.18 and saw no problem.
> Of course, my configuration was probably different and I wasn't
> running Gentoo.   Eth0 was a sky2 device, and eth1 was a skge.
> 

This turned out to be a netfilter configuration issue. sky2+iptables 
works fine when the kernel is compiled correctly. Sorry for the noise, 
although the netfilter error messages weren't exactly clear that certain 
modules were missing!

Daniel
