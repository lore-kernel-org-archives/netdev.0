From: Andy Whitcroft <apw@canonical.com>
Subject: Re: [PATCH v2] checkpatch: add double empty line check
Date: Tue, 20 Nov 2012 16:36:55 +0000
Message-ID: <20121120163655.GC17797@dm>
References: <1353151057.14327.18.camel@lb-tlvb-eilong.il.broadcom.com>
 <20121120115239.GA7955@dm>
 <1353421624.6559.9.camel@lb-tlvb-eilong.il.broadcom.com>
 <20121120144329.GE7955@dm>
 <1353424027.6559.15.camel@lb-tlvb-eilong.il.broadcom.com>
 <20121120154443.GK7955@dm>
 <1353427570.6559.21.camel@lb-tlvb-eilong.il.broadcom.com>
 <20121120161417.GA17797@dm>
 <1353428544.6559.26.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>,
	David Rientjes <rientjes@google.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1353428544.6559.26.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 20, 2012 at 06:22:24PM +0200, Eilon Greenstein wrote:
> On Tue, 2012-11-20 at 16:14 +0000, Andy Whitcroft wrote:
> > On Tue, Nov 20, 2012 at 06:06:10PM +0200, Eilon Greenstein wrote:
> > > I'm only testing the nextline if the current line is newly added. If I
> > > got it right, when a line is newly added, the next line can be:
> > > a. another new line
> > > b. existing line (provided for context)
> > > c. Does not exist since this is the end of the file (I missed this one
> > > originally)
> > > 
> > > It cannot just jump to the next hunk and it cannot be a deleted line,
> > > right?
> > 
> > Mostly that would be true.  If the hunk is the last hunk and adds lines
> > at the bottom of a file _and_ the context around it has blank lines then
> > something.  I think that would trip up this algorithm, reporting beyond
> > the end of the hunk perhaps.
> 
> I do not want to cause any perl warning, but adding a new segment that
> ends with a new empty line above an existing empty line is something
> that I want to catch - so checking the next line (even if it is not new)
> is desired. Do you have other suggestions on how to implement something
> like that?
> 
> I'm not saying that my patch is safe - I already missed a corner case
> when adding a line at the end of the file, but I'm willing to run more
> tests and see if I hit some perl warning. So how about running it on the
> last X changes in the kernel git tree? How many tests are enough to get
> reasonable confidant level?

I have been testing the patches there with some fake files to try and
catch these indeed.  I did incldue my take on how to solve this in
previous replies.

-apw
