From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 2/3] r8169: Large Send enablement
Date: Thu, 4 Nov 2004 19:45:29 +0100
Message-ID: <20041104184529.GA2694@electric-eye.fr.zoreil.com>
References: <200411021203.22003.jdmason@us.ibm.com> <20041102191103.GA24860@electric-eye.fr.zoreil.com> <200411031816.11675.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon Mason <jdmason@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <200411031816.11675.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jon Mason <jdmason@us.ibm.com> :
> On Tuesday 02 November 2004 01:11 pm, Francois Romieu wrote:
> [...]
> > - If rtl8169_open() fails [*] when the device was previously up, the driver
> >   could/should try to recover.
> 
> I disagree.  It should fail, complain loudly, and let the user try and fix it 
> (or return it to the previous state).  The code provided below will act like 

Mmmm... Actually both patches try to paper over the real issue: the driver
should reserve the ressources it needs for the change of mtu first.
Ok, I'll take the patch provided I can't find anything badly racy in it and
focus on the 8139C+/8169 merge. It has already been delayed for too long
and it seems the right place to fix the aforementionned issue with style :o)

--
Ueimor
