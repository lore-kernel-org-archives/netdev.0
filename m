From: Andy Whitcroft <apw@canonical.com>
Subject: Re: [PATCH v2] checkpatch: add double empty line check
Date: Tue, 20 Nov 2012 20:11:42 +0000
Message-ID: <20121120201142.GI17797@dm>
References: <20121120115239.GA7955@dm>
 <1353421624.6559.9.camel@lb-tlvb-eilong.il.broadcom.com>
 <20121120144329.GE7955@dm>
 <1353424027.6559.15.camel@lb-tlvb-eilong.il.broadcom.com>
 <20121120154443.GK7955@dm>
 <1353427570.6559.21.camel@lb-tlvb-eilong.il.broadcom.com>
 <20121120161417.GA17797@dm>
 <20121120163607.GB17797@dm>
 <1353438635.10779.10.camel@lb-tlvb-eilong.il.broadcom.com>
 <20121120193249.GH17797@dm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>,
	David Rientjes <rientjes@google.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20121120193249.GH17797@dm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 20, 2012 at 07:32:49PM +0000, Andy Whitcroft wrote:
> On Tue, Nov 20, 2012 at 09:10:35PM +0200, Eilon Greenstein wrote:
> 
> > About the logic - true, if diff will show deleted lines after newly
> > added lines, some new double line segments will be missed. However, it
> > seems like few other things will break if diff will start acting out
> > like that. The suggestion you posted earlier will miss those as well,
> > and starting to check for this weird case (of deleted lines after the
> > added lines) does not seem right.
> 
> Actually the version I sent should indeed cope with the deleted lines
> regardless of order.  It was cirtainly intended to.

... and I think I thought of a couple more corner cases neither solution
will find.  So I am going to go away and make up a proper set of tests
for this apparently simple change.  As it is really annoying when it
false positives.  I will post against when I have something which works.

-apw
