From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/2] r8169: RTL8169_registers clean-up
Date: Mon, 28 Feb 2005 23:03:02 +0100
Message-ID: <20050228220302.GC8186@electric-eye.fr.zoreil.com>
References: <20050228190444.GA13415@us.ibm.com> <20050228195958.GB8186@electric-eye.fr.zoreil.com> <200502281507.37909.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
To: Jon Mason <jdmason@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200502281507.37909.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Mason <jdmason@us.ibm.com> :
[...]
> > 1 - It does not use bitwise shifts where possible (suggested by Jeff);
> 
> I never heard from you that this was the way to go.  I can do this, if you 
> still want this patch.

This was not from me but from Jeff Garzik on 26/02/2005:
- Message-ID: <4220B9C6.1010106@pobox.com>
- Subject: [PATCH]: r8169: Expose hardware stats via ethtool

Said mail contained "Cleanup patches accepted.", so I did not question
the sanity of the patch. :o)

[lack of consistency]
> Not seeing where you are refering to, can you give me a line #?

--- drivers/net/r8169.c 2005-02-27 11:45:27.000000000 -0600
+++ drivers/net/r8169.c.new     2005-02-27 11:44:44.000000000 -0600
@@ -186,91 +186,91 @@ static int rx_copybreak = 200;
 static int use_dac;

 enum RTL8169_registers {
-       MAC0 = 0,               /* Ethernet hardware address. */
-       MAR0 = 8,               /* Multicast filter. */
+       MAC0            = 0x00, /* Ethernet hardware address. */
+       MAR0            = 0x08, /* Multicast filter. */
        TxDescStartAddrLow = 0x20,
        TxDescStartAddrHigh = 0x24,
        TxHDescStartAddrLow = 0x28,
        TxHDescStartAddrHigh = 0x2c,

[...]
> > 3 - Please write a script to reduce the patch and prove that a typo does
> >     not hide somewhere (yep, I'm lazy). It would take too much testing
> >     to get a complete coverage.
> 
> If you are that worried, it probably isn't worth it.  Its just clean-up ;-)

I just want a cleanup patch to be easy to review: either #1 simple rules
allow to check it or #2 it can be proven that it is right.

The r8169 driver already went through misc cleanups lately. We can surely
spend some time hacking it again before it hurts the good taste (TM).

Back to the update/merge/compile fest...

--
Ueimor
