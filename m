From: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Subject: Re: fealnx oopses (with [PATCH])
Date: Thu, 1 Apr 2004 14:09:37 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404011409.37628.vda@port.imtp.ilyichevsk.odessa.ua>
References: <200403261214.58127.vda@port.imtp.ilyichevsk.odessa.ua> <406B2FB5.9080302@pobox.com> <20040401002325.A9022@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com, Andreas Henriksson <andreas@fjortis.info>,
        Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>, Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20040401002325.A9022@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 01 April 2004 01:23, Francois Romieu wrote:
> Jeff Garzik <jgarzik@pobox.com> :
> > FYI to those involved, I sent the TX patch upstream.
> >
> > When there is a minimal RX patch people are happy with, let me know...
> > further changes are fine, but I would like to split up the changes as
> > much as is reasonable.
>
> Attached is the patch tested by Andreas which fixes single allocation
> failures but will not protect against excessive work in irq handler nor
> complete depletion of the Rx ring.
>
> It applies on top of the Tx patch (as seen on bk-commit).
>
> Earth-shattering, anyone ?

Yes, this thing improved life for me (from oopses
to uninterruptible excessive work in interrupt).
My RX coding was on top of it, so I think this should
be applied.

Jeff?
-- 
vda
