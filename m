From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Acer Aspire 1524WLMi and RealTek 8169 - very slow
Date: Sun, 23 Jan 2005 00:01:56 +0100
Message-ID: <20050122230156.GC24461@electric-eye.fr.zoreil.com>
References: <41A09541.5040405@phekda.gotadsl.co.uk> <41A0F0D5.9050702@phekda.gotadsl.co.uk> <20041121205814.GA22460@electric-eye.fr.zoreil.com> <41A24F35.5080106@phekda.gotadsl.co.uk> <20041122213008.GA9618@electric-eye.fr.zoreil.com> <41D2844E.5070204@phekda.gotadsl.co.uk> <20041229235203.GA5465@electric-eye.fr.zoreil.com> <41F250D1.8000207@phekda.gotadsl.co.uk> <41F26FD1.2060407@phekda.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Richard Dawe <rich@phekda.gotadsl.co.uk>
Content-Disposition: inline
In-Reply-To: <41F26FD1.2060407@phekda.gotadsl.co.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Richard Dawe <rich@phekda.gotadsl.co.uk> :
[...]
> So I looked at the latest RealTek driver for Linux (version 220) and 
> that has some separate initialisation code for RTL_GIGA_MAC_VER_X 
> (MCFG_METHOD_4, they call it). I ported that over to r8169.c in 
> 2.6.11-rc1 and it appears to work.

Nice. Have you checked that ethtool performs correctly when you try to
set the link parameters with the new code (+ plug/unplug cable) ?

> Attached is the patch against 2.6.11-rc1. I'm not sure if it caters to 
> your tastes. Maybe you'll want to rename RTL_GIGA_MAC_VER_X. 

I'll change the braces placement, the tab/spaces mix and push it.

Please include something like the line below in your future patches:
Signed-off-by: Richard Dawe <rich@phekda.gotadsl.co.uk>

Thanks.

--
Ueimor
