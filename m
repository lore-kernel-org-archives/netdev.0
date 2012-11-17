From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] checkpatch: add double empty line check
Date: Fri, 16 Nov 2012 16:50:54 -0800
Message-ID: <1353113454.2512.21.camel@joe-AO722>
References: <1353094919.14327.4.camel@lb-tlvb-eilong.il.broadcom.com>
	 <alpine.DEB.2.00.1211161154280.2788@chino.kir.corp.google.com>
	 <1353096274.14327.9.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Rientjes <rientjes@google.com>,
	Andy Whitcroft <apw@canonical.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: eilong@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1353096274.14327.9.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-11-16 at 22:04 +0200, Eilon Greenstein wrote:
> On Fri, 2012-11-16 at 11:55 -0800, David Rientjes wrote:
> > On Fri, 16 Nov 2012, Eilon Greenstein wrote:
> > 
> > > diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
> > > index 21a9f5d..7a9c153 100755
> > > --- a/scripts/checkpatch.pl
> > > +++ b/scripts/checkpatch.pl
> > > @@ -3579,6 +3579,13 @@ sub process {
> > >  			WARN("EXPORTED_WORLD_WRITABLE",
> > >  			     "Exporting world writable files is usually an error. Consider more restrictive permissions.\n" . $herecurr);
> > >  		}
> > > +
> > > +# check for double empty lines
> > > +		if ($line =~ /^\+\s*$/ &&
> > > +		    ($prevline =~ /^\+?\s*$/ || $rawlines[$linenr] =~ /^\s*$/)) {
> > > +			WARN("DOUBLE_EMPTY_LINE",
> > > +			     "One empty line should be sufficient. Consider removing this one.\n" . $herecurr);
> > > +		}
> > >  	}
> > >  
> > >  	# If we have no input at all, then there is nothing to report on
> > 
> > This is fairly common in all the acpi code where variables declared in a 
> > function are separated from the code in a function.
> > 
> 
> Indeed, I see that you do use it in some functions.
> 
> Maybe we can limit it only to the networking tree (similar to the
> networking comments style) or if the ACPI is the exception, we can apply
> to all but ACPI.

I'm not sure this should be done.
Double line spacing has some utility and
is pretty common.

Perhaps make this a --strict/CHK option
and also perhaps make sure this isn't
emitted on consecutive lines.
