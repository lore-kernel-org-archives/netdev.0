From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2] checkpatch: add double empty line check
Date: Tue, 20 Nov 2012 15:41:14 -0800
Message-ID: <1353454874.17819.41.camel@joe-AO722>
References: <1353151057.14327.18.camel@lb-tlvb-eilong.il.broadcom.com>
	 <20121120115239.GA7955@dm> <1353448728.17819.33.camel@joe-AO722>
	 <20121120231930.GA27492@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eilon Greenstein <eilong@broadcom.com>,
	David Rientjes <rientjes@google.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Andy Whitcroft <apw@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121120231930.GA27492@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-11-20 at 23:19 +0000, Andy Whitcroft wrote:
> On Tue, Nov 20, 2012 at 01:58:48PM -0800, Joe Perches wrote:
> 
> > +# check for multiple blank lines, warn only on the second one in a block
> > +		if ($rawline =~ /^.\s*$/ &&
> > +		    $prevrawline =~ /^.\s*$/ &&
> > +		    $linenr != $last_blank_linenr + 1) {
> > +			CHK("DOUBLE_EMPTY_LINE",
> > +			    "One blank line separating blocks is generally sufficient\n" . $herecurr);
> > +			$last_blank_linenr = $linenr;
> > +		}
> > +
> >  # check for line continuations in quoted strings with odd counts of "
> >  		if ($rawline =~ /\\$/ && $rawline =~ tr/"/"/ % 2) {
> >  			WARN("LINE_CONTINUATIONS",
> 
> Pretty sure that will fail with combination which have removed lines.

Not as far as I can tell.
Deleted lines followed by inserted lines seem
to work OK.

This check is located after the test that ensures
the current $line/$rawline is an insertion.

> I have a version here which I am testing with the combinations I have
> isolated to far ...

Enjoy.
Can you please test my proposal against those combinations too?

cheers, Joe
