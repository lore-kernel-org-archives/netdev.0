From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: Poor gige performance with 2.4.20-pre*
Date: Sun, 29 Sep 2002 20:45:10 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020929204510.A26826@redhat.com>
References: <200209282257.g8SMvta32527@vindaloo.ras.ucalgary.ca> <002f01c2675d$b642b640$f5f2010a@weixl> <200209290634.g8T6Y2o08439@vindaloo.ras.ucalgary.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Xiaoliang (David) Wei" <weixl@caltech.edu>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Richard Gooch <rgooch@ras.ucalgary.ca>
Content-Disposition: inline
In-Reply-To: <200209290634.g8T6Y2o08439@vindaloo.ras.ucalgary.ca>; from rgooch@ras.ucalgary.ca on Sun, Sep 29, 2002 at 12:34:02AM -0600
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Sep 29, 2002 at 12:34:02AM -0600, Richard Gooch wrote:
> This is all on a LAN (of course; expecting good performance from a WAN
> is pretty futile). I use a buffer size of 256 KiB.

>From my experience tuning on a 550MHz P3 Xeon, you're better off using a 
buffer size of 8-16KB that stays in the L1 cache.  Of course, that was 
without actually doing anything useful with the data being transferred.  
Gige really does need a faster cpu in the ghz+ range.  As for ns83820, 
it's a work in progress.  Some of the recent bugfixes may have reduced 
performance, so it may need to be retuned.

		-ben
-- 
GMS rules.
