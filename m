From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH 2/3] r8169: Large Send enablement
Date: Fri, 5 Nov 2004 05:50:33 +0000
Message-ID: <200411050550.33521.jdmason@us.ibm.com>
References: <200411021203.22003.jdmason@us.ibm.com> <200411031816.11675.jdmason@us.ibm.com> <20041104184529.GA2694@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20041104184529.GA2694@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 04 November 2004 06:45 pm, Francois Romieu wrote:
> Jon Mason <jdmason@us.ibm.com> :
> > On Tuesday 02 November 2004 01:11 pm, Francois Romieu wrote:
> > [...]
> >
> > > - If rtl8169_open() fails [*] when the device was previously up, the
> > > driver could/should try to recover.
> >
> > I disagree.  It should fail, complain loudly, and let the user try and
> > fix it (or return it to the previous state).  The code provided below
> > will act like
>
> Mmmm... Actually both patches try to paper over the real issue: the driver
> should reserve the resources it needs for the change of mtu first.

Agreed.  I did a quick look in the other drivers, and didn't find any drivers 
that handle this possibility.  Most of them ignore the fact.  This sounds 
like an open hole in all of the drivers.
