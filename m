From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [PATCH] checkpatch: add double empty line check
Date: Fri, 16 Nov 2012 22:04:34 +0200
Message-ID: <1353096274.14327.9.camel@lb-tlvb-eilong.il.broadcom.com>
References: <1353094919.14327.4.camel@lb-tlvb-eilong.il.broadcom.com>
 <alpine.DEB.2.00.1211161154280.2788@chino.kir.corp.google.com>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Andy Whitcroft" <apw@canonical.com>, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: "David Rientjes" <rientjes@google.com>,
	"Joe Perches" <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1211161154280.2788@chino.kir.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-11-16 at 11:55 -0800, David Rientjes wrote:
> On Fri, 16 Nov 2012, Eilon Greenstein wrote:
> 
> > diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
> > index 21a9f5d..7a9c153 100755
> > --- a/scripts/checkpatch.pl
> > +++ b/scripts/checkpatch.pl
> > @@ -3579,6 +3579,13 @@ sub process {
> >  			WARN("EXPORTED_WORLD_WRITABLE",
> >  			     "Exporting world writable files is usually an error. Consider more restrictive permissions.\n" . $herecurr);
> >  		}
> > +
> > +# check for double empty lines
> > +		if ($line =~ /^\+\s*$/ &&
> > +		    ($prevline =~ /^\+?\s*$/ || $rawlines[$linenr] =~ /^\s*$/)) {
> > +			WARN("DOUBLE_EMPTY_LINE",
> > +			     "One empty line should be sufficient. Consider removing this one.\n" . $herecurr);
> > +		}
> >  	}
> >  
> >  	# If we have no input at all, then there is nothing to report on
> 
> This is fairly common in all the acpi code where variables declared in a 
> function are separated from the code in a function.
> 

Indeed, I see that you do use it in some functions.

Maybe we can limit it only to the networking tree (similar to the
networking comments style) or if the ACPI is the exception, we can apply
to all but ACPI.
