From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH 2/2] r8169: RTL8169_registers clean-up
Date: Mon, 28 Feb 2005 15:07:37 -0600
Message-ID: <200502281507.37909.jdmason@us.ibm.com>
References: <20050228190444.GA13415@us.ibm.com> <20050228195958.GB8186@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20050228195958.GB8186@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Monday 28 February 2005 01:59 pm, Francois Romieu wrote:
> Jon Mason <jdmason@us.ibm.com> :
> > An attempt to clean-up RTL8169_registers and  RTL8169_register_content.
> > Adjusted tab alignment and converted decimal values to hex.
> >
> > Applies cleanly to linux-2.6.11-rc4-mm1 and tested on amd64

Ya, I've already gotten some private e-mail grief.  

> 1 - It does not use bitwise shifts where possible (suggested by Jeff);

I never heard from you that this was the way to go.  I can do this, if you 
still want this patch.

> 2 - It is not consistent (see TxDesc...);

Not seeing where you are refering to, can you give me a line #?

> 3 - Please write a script to reduce the patch and prove that a typo does
>     not hide somewhere (yep, I'm lazy). It would take too much testing
>     to get a complete coverage.

If you are that worried, it probably isn't worth it.  Its just clean-up ;-)

-- 
Jon Mason
jdmason@us.ibm.com
