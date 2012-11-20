From: Andy Whitcroft <apw@canonical.com>
Subject: Re: [PATCH v2] checkpatch: add double empty line check
Date: Tue, 20 Nov 2012 16:36:07 +0000
Message-ID: <20121120163607.GB17797@dm>
References: <1353151057.14327.18.camel@lb-tlvb-eilong.il.broadcom.com>
 <20121120115239.GA7955@dm>
 <1353421624.6559.9.camel@lb-tlvb-eilong.il.broadcom.com>
 <20121120144329.GE7955@dm>
 <1353424027.6559.15.camel@lb-tlvb-eilong.il.broadcom.com>
 <20121120154443.GK7955@dm>
 <1353427570.6559.21.camel@lb-tlvb-eilong.il.broadcom.com>
 <20121120161417.GA17797@dm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>,
	David Rientjes <rientjes@google.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121120161417.GA17797@dm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 20, 2012 at 04:14:17PM +0000, Andy Whitcroft wrote:
> On Tue, Nov 20, 2012 at 06:06:10PM +0200, Eilon Greenstein wrote:
> > I'm only testing the nextline if the current line is newly added. If I
> > got it right, when a line is newly added, the next line can be:
> > a. another new line
> > b. existing line (provided for context)
> > c. Does not exist since this is the end of the file (I missed this one
> > originally)
> > 
> > It cannot just jump to the next hunk and it cannot be a deleted line,
> > right?

Oh and in theory at least it could be a - line, though diff never
generates things in that order.

-apw
