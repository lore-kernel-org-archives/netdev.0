From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: fealnx oopses (with [PATCH])
Date: Thu, 1 Apr 2004 14:28:57 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040401142857.A21268@electric-eye.fr.zoreil.com>
References: <200403261214.58127.vda@port.imtp.ilyichevsk.odessa.ua> <406B2FB5.9080302@pobox.com> <20040401002325.A9022@electric-eye.fr.zoreil.com> <200404011409.37628.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
        Andreas Henriksson <andreas@fjortis.info>
Return-path: <netdev-bounce@oss.sgi.com>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Content-Disposition: inline
In-Reply-To: <200404011409.37628.vda@port.imtp.ilyichevsk.odessa.ua>; from vda@port.imtp.ilyichevsk.odessa.ua on Thu, Apr 01, 2004 at 02:09:37PM +0300
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua> :
[...]
> Yes, this thing improved life for me (from oopses
> to uninterruptible excessive work in interrupt).
> My RX coding was on top of it, so I think this should
> be applied.

<bozo>
The patch includes an unneeded 'return' removal which will choke (it is
already done in the Tx patch sent by Jeff).
</bozo>

Should I rediff and send directly to Jeff ?

--
Ueimor
