From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: Re: finding your own dead "CONFIG_" variables
Date: Thu, 3 May 2007 05:49:10 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0705030546310.29962@localhost.localdomain>
References: <Pine.LNX.4.64.0705030400120.20539@localhost.localdomain>
 <a781481a0705030237l7d636b55t93f2ee5151cd7709@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Satyam Sharma <satyam.sharma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:48758 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030991AbXECJth (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 05:49:37 -0400
In-Reply-To: <a781481a0705030237l7d636b55t93f2ee5151cd7709@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 3 May 2007, Satyam Sharma wrote:

> > http://fsdev.net/wiki/index.php?title=Dead_CONFIG_variables
>
> > kcfiles=$(find . -name "Kconfig*")
>
> Suggest: configfiles=$(find . -name 'Kconfig*' -or -name '*defconfig*')
>
> Some CONFIG_ options exist that are not declared anywhere in the
> Kconfig files but defined directly in the arch/.../*defconfig*
> files.

it's my understanding that entries in any defconfig files are
*automatically* pruned at some point once a CONFIG_ variable no longer
exists in any Kconfig file, so i'm not going to be touching those
files.  also, adding that extra check wouldn't add anything useful to
the output.

rday

-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================
