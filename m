From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [patch net-next] cxgb3: update firmware version
Date: Tue, 14 Feb 2012 22:02:46 +0000
Message-ID: <20120214220246.GV12704@decadent.org.uk>
References: <20120213202846.631.30806.stgit@speedy5.asicdesigners.com>
 <1329165817.2092.62.camel@shinybook.infradead.org>
 <4F398303.1030606@chelsio.com>
 <1329184754.3048.33.camel@deadeye>
 <4F39E7C9.20901@chelsio.com>
 <1329196116.3048.66.camel@deadeye>
 <4F39F75D.6030107@chelsio.com>
 <4F3AA537.4050700@hp.com>
 <20120214182110.GO12704@decadent.org.uk>
 <4F3ABDD2.4000207@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Divy Le Ray <divy@chelsio.com>,
	David Woodhouse <dwmw2@infradead.org>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Steve Wise <swise@opengridcomputing.com>, nhorman@tuxdriver.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:56658 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757108Ab2BNWDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 17:03:01 -0500
Content-Disposition: inline
In-Reply-To: <4F3ABDD2.4000207@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 14, 2012 at 12:02:26PM -0800, Rick Jones wrote:
> On 02/14/2012 10:21 AM, Ben Hutchings wrote:
> >On Tue, Feb 14, 2012 at 10:17:27AM -0800, Rick Jones wrote:
> >>What does an end-user/customer see and do?  When they are told that
> >>version the firmware, specified down to the fix level, fixes a
> >>problem they are having, how will they know that firmware blob
> >>filename drvfw-X.bin on a download/archive site has that fix?
> >[...]
> >
> >Customers currently can't get bug fixes by updating the firmware.
> >Think about it.
> 
> Because in this case at least the driver is requesting a specific
> filename down to the minor and micro level and a change in the
> filename requires a change in the driver?
>
> #define FW_VERSION __stringify(FW_VERSION_MAJOR) "."                    \
>         __stringify(FW_VERSION_MINOR) "." __stringify(FW_VERSION_MICRO)
> #define FW_FNAME "cxgb3/t3fw-" FW_VERSION ".bin"
> 
> rather than the driver having logic to make it willing to accept
> later minor/micro changes by being more sophisticated in its
> specification of firmware file.
 
Well, you can't really be very sophisticated as there is no way to
list the available firmware files.

The Intel wireless drivers try iterating from the newest to oldest
supported API version.  But that API version is changed only rarely.
If you were to iterate over some wide range of potential future
versions it could take a substantial time to find the file that's
actualy installed.

Ben.

-- 
Ben Hutchings
We get into the habit of living before acquiring the habit of thinking.
                                                              - Albert Camus
