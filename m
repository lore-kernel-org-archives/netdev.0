From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: 2.6.4-rc1 + hp100 EISA, not working
Date: Thu, 4 Mar 2004 09:26:50 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040304092650.2575fd1c@dell_ss3.pdx.osdl.net>
References: <Pine.LNX.4.58.0402292149230.25624@don.falconne.eu.org>
	<wrpk724yicq.fsf@hina.wild-wind.fr.eu.org>
	<20040303122541.4dbcf0fc@dell_ss3.pdx.osdl.net>
	<Pine.LNX.4.58.0403040550150.25624@don.falconne.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: falcon@muflon.linux.pl, mzyngier@freesurf.fr, netdev@oss.sgi.com,
        jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: pawel.sokolowski@muflon.linux.pl
In-Reply-To: <Pine.LNX.4.58.0403040550150.25624@don.falconne.eu.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

 
> eisa_bus_match dev sig='HWPC061' state=0x1 eids=HWPF180
> eisa_bus_match dev sig='HWP1940' state=0x3 eids=HWPF180
> 
> without:
> 
> eisa_bus_match dev sig='HWPC061' state=0x1 eids=HWPF180
> eisa_bus_match dev sig='HWP1940' state=0x0 eids=HWPF180
> 
> when modprobing hp100.

The name HWP1940 is in the table, so that looks okay.
Can you build with HP100_DEBUG defined?
