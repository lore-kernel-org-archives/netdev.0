From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: fealnx oopses
Date: Mon, 29 Mar 2004 09:52:01 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403290952.01687.vda@port.imtp.ilyichevsk.odessa.ua>
References: <200403261214.58127.vda@port.imtp.ilyichevsk.odessa.ua> <200403282219.56799.vda@port.imtp.ilyichevsk.odessa.ua> <20040328232707.GA17524@scream.fjortis.info>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, Jeff Garzik <jgarzik@pobox.com>,
        Andreas Henriksson <andreas@fjortis.info>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andreas Henriksson <andreas@fjortis.info>
In-Reply-To: <20040328232707.GA17524@scream.fjortis.info>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Monday 29 March 2004 01:27, Andreas Henriksson wrote:
> On Sun, Mar 28, 2004 at 10:19:56PM +0200, Denis Vlasenko wrote:
> > I tested on 2.4.25, patch applied with minimal manual correction
> > in last hunk (rediffed patch attached).
>
> I tested on 2.6.5-rc2-bk7 ... with both jeffs (which was exactly the
> same patch I had except for removing the return at the end of the void
> function) and francis patches...
>
> Btw. I haven't seen any panics at all because of rx, just tx, and that
> problem seems solved. But I thought testing additional patches that
> is supposed to cure other problems won't hurt me.. ;)

Thank you, you verified that _I_ did not caused it.
(I could, I was a bit tired at the time)

You need to make your box very RAM starved for this.
I boot with mem=16M and load all iptables NAT/conntrack
modules to make network processing more CPU/RAM intensive.
-- 
vda
