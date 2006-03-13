From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] TC: bug fixes to the "sample" clause
Date: Mon, 13 Mar 2006 20:02:02 +0100
Message-ID: <4415C1AA.1010500@trash.net>
References: <1139538806.15476.33.camel@ras>	<1142082696.5184.53.camel@jzny2>	<1142225063.14909.77.camel@ras.pc.brisbane.lube>	<1142269090.5242.29.camel@jzny2>	<4415B217.30507@trash.net>
	<20060313100421.7df7f9ed@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca, lartc@mailman.ds9a.nl
Return-path: <lartc-bounces@mailman.ds9a.nl>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060313100421.7df7f9ed@localhost.localdomain>
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
>>BTW, running valgrind on tc shows lots of uses of uninitialized values,
>>it seems like a good idea if someone would go over these and fix them
>>up.
> 
> 
> If we had a test script of commands (code coverage), that would help.

Actually the Coverity scanner is quite good at spotting these problems,
so I've requested iproute to be added to the list of regulary scanned
projects.
