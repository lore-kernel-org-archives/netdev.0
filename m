From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/2] r8169: RTL8169_registers clean-up
Date: Mon, 28 Feb 2005 20:59:58 +0100
Message-ID: <20050228195958.GB8186@electric-eye.fr.zoreil.com>
References: <20050228190444.GA13415@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
To: Jon Mason <jdmason@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <20050228190444.GA13415@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Mason <jdmason@us.ibm.com> :
> An attempt to clean-up RTL8169_registers and  RTL8169_register_content.
> Adjusted tab alignment and converted decimal values to hex.
> 
> Applies cleanly to linux-2.6.11-rc4-mm1 and tested on amd64

1 - It does not use bitwise shifts where possible (suggested by Jeff);
2 - It is not consistent (see TxDesc...);
3 - Please write a script to reduce the patch and prove that a typo does
    not hide somewhere (yep, I'm lazy). It would take too much testing
    to get a complete coverage.

Jeff, how am I supposed to handle cleanups now ? Just say no ? :o)

--
Ueimor
