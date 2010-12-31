From: Dan Carpenter <error27@gmail.com>
Subject: Re: [PATCH 02/15]drivers:spi:dw_spi.c Typo change diable to
 disable.
Date: Fri, 31 Dec 2010 20:41:00 +0300
Message-ID: <20101231174100.GF1886@bicker>
References: <1293750484-1161-1-git-send-email-justinmattock@gmail.com>
 <1293750484-1161-2-git-send-email-justinmattock@gmail.com>
 <20101231064515.GC3733@angua.secretlab.ca>
 <4D1D7DAE.7060504@gmail.com>
 <20101231091136.GC1886@bicker>
 <4D1DE616.7010105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Likely <grant.likely@secretlab.ca>, trivial@kernel.org,
	devel@driverdev.osuosl.org, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	ivtv-devel@ivtvdriver.org, linux-m68k@lists.linux-m68k.org,
	spi-devel-general@lists.sourceforge.net,
	linux-media@vger.kernel.org
To: "Justin P. Mattock" <justinmattock@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4D1DE616.7010105@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 31, 2010 at 06:17:58AM -0800, Justin P. Mattock wrote:
> >Wrong:  [PATCH 02/15]drivers:spi:dw_spi.c Typo change diable to disable.
> >
> >Right:  [PATCH 02/15] spi/dw_spi: Typo change diable to disable
> >
> >regards,
> >dan carpenter
> >
> 
> alright.. so having the backlash is alright for the subject

Well really my point is not so much about backslashes vs colons, it's
about getting the *one* correct prefix.  This stuff is probably
scriptable most of the time, but you may still be required to think a
little on the corner cases.

Here is a script to get you started.

git log --format="%s" drivers/spi/dw_spi.c | \
	head -n 20 |                         \
	perl -ne 's/(.*):.*/$1/; print' |    \
	sort | uniq -c | sort -rn |          \
	perl -ne 's/^\W+\d+ //; print' |     \
	head -n 1

regards,
dan carpenter
