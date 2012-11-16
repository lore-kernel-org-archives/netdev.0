From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] checkpatch: add double empty line check
Date: Fri, 16 Nov 2012 11:55:04 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1211161154280.2788@chino.kir.corp.google.com>
References: <1353094919.14327.4.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andy Whitcroft <apw@canonical.com>, linux-kernel@vger.kernel.org,
	Joe Perches <joe@perches.com>, netdev <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1353094919.14327.4.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 16 Nov 2012, Eilon Greenstein wrote:

> diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
> index 21a9f5d..7a9c153 100755
> --- a/scripts/checkpatch.pl
> +++ b/scripts/checkpatch.pl
> @@ -3579,6 +3579,13 @@ sub process {
>  			WARN("EXPORTED_WORLD_WRITABLE",
>  			     "Exporting world writable files is usually an error. Consider more restrictive permissions.\n" . $herecurr);
>  		}
> +
> +# check for double empty lines
> +		if ($line =~ /^\+\s*$/ &&
> +		    ($prevline =~ /^\+?\s*$/ || $rawlines[$linenr] =~ /^\s*$/)) {
> +			WARN("DOUBLE_EMPTY_LINE",
> +			     "One empty line should be sufficient. Consider removing this one.\n" . $herecurr);
> +		}
>  	}
>  
>  	# If we have no input at all, then there is nothing to report on

This is fairly common in all the acpi code where variables declared in a 
function are separated from the code in a function.
