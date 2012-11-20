From: Andy Whitcroft <apw@canonical.com>
Subject: Re: [PATCH v2] checkpatch: add double empty line check
Date: Tue, 20 Nov 2012 23:19:30 +0000
Message-ID: <20121120231930.GA27492@localhost>
References: <1353151057.14327.18.camel@lb-tlvb-eilong.il.broadcom.com>
 <20121120115239.GA7955@dm>
 <1353448728.17819.33.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eilon Greenstein <eilong@broadcom.com>,
	David Rientjes <rientjes@google.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1353448728.17819.33.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 20, 2012 at 01:58:48PM -0800, Joe Perches wrote:

> +# check for multiple blank lines, warn only on the second one in a block
> +		if ($rawline =~ /^.\s*$/ &&
> +		    $prevrawline =~ /^.\s*$/ &&
> +		    $linenr != $last_blank_linenr + 1) {
> +			CHK("DOUBLE_EMPTY_LINE",
> +			    "One blank line separating blocks is generally sufficient\n" . $herecurr);
> +			$last_blank_linenr = $linenr;
> +		}
> +
>  # check for line continuations in quoted strings with odd counts of "
>  		if ($rawline =~ /\\$/ && $rawline =~ tr/"/"/ % 2) {
>  			WARN("LINE_CONTINUATIONS",

Pretty sure that will fail with combination which have removed lines.  I
have a version here which I am testing with the combinations I have
isolated to far ...

-apw
