From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: fealnx oopses
Date: Wed, 31 Mar 2004 23:01:25 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040331230125.A9130@electric-eye.fr.zoreil.com>
References: <200403261214.58127.vda@port.imtp.ilyichevsk.odessa.ua> <20040330002047.D4744@electric-eye.fr.zoreil.com> <200403300050.42367.vda@port.imtp.ilyichevsk.odessa.ua> <200403300116.41377.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Henriksson <andreas@fjortis.info>, Jeff Garzik <jgarzik@pobox.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Content-Disposition: inline
In-Reply-To: <200403300116.41377.vda@port.imtp.ilyichevsk.odessa.ua>; from vda@port.imtp.ilyichevsk.odessa.ua on Tue, Mar 30, 2004 at 01:16:41AM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua> :
[...]
> I just verified that even if I stop remote netcat,
> box does not recover. Console fills with
> "Too much work at interrupt, status=0x0020"
> 0x0020 is RBU = 0x00000020, /* receive buffer unavailable */

There too much work in my daily interrupt handler as well so this get
scheduled for a few days/nights :o)

If anything else, I'll probably cook up a nice patch for the current changes
once things settle down a bit. 

--
Ueimor
