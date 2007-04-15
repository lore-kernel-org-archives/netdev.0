From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: intermittant petabyte usage reported with broadcom nic
Date: Sat, 14 Apr 2007 17:20:01 -0700
Message-ID: <1176596401.5847.7.camel@dell>
References: <20070402014319.GA8345@zip.com.au>
 <20070402001300.3b66007d.akpm@linux-foundation.org>
 <20070402074108.GB8345@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Andrew Morton" <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "CaT" <cat@zip.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3252 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752841AbXDNXec (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Apr 2007 19:34:32 -0400
In-Reply-To: <20070402074108.GB8345@zip.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-04-02 at 17:41 +1000, CaT wrote:
> On Mon, Apr 02, 2007 at 12:13:00AM -0700, Andrew Morton wrote:
> > On Mon, 2 Apr 2007 11:43:19 +1000 CaT <cat@zip.com.au> wrote:
> > 
> > > I take minute by minute snapshots of network traffic by sampling
> > > /proc/net/dev and most of the time everything works fine. Occasionally
> > > though I get petabyte byte traffic and corresponding packet traffic.
> > 
> > How frequently?
> 
> I can count about 6 over the past month.
> 
I did a quick test on a 64-bit kernel and did not see any problem with
the counters.  I'll ask the lab to set up a longer term test and monitor
the counters for bogus values.

I also like Andi's idea of using change_page_attr() to isolate the
problem.  I'll try to send you a debug patch in the next few days to try
that out.  Thanks.

