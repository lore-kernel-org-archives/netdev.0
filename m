From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [V2 PATCH 2/9] csiostor: Chelsio FCoE offload driver submission
 (sources part 2).
Date: Wed, 5 Sep 2012 15:59:56 -0700
Message-ID: <20120905155956.561b172d@nehalam.linuxnetplumber.net>
References: <1346848442-4573-1-git-send-email-naresh@chelsio.com>
	<1346848442-4573-3-git-send-email-naresh@chelsio.com>
	<20120905092957.7d24187e@nehalam.linuxnetplumber.net>
	<50478F52.208@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "JBottomley@parallels.com" <JBottomley@parallels.com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	Dimitrios Michailidis <dm@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chethan Seshadri <chethan@chelsio.com>
To: Naresh Kumar Inna <naresh@chelsio.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <50478F52.208@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 5 Sep 2012 23:13:46 +0530
Naresh Kumar Inna <naresh@chelsio.com> wrote:

> On 9/5/2012 9:59 PM, Stephen Hemminger wrote:
> > On Wed,  5 Sep 2012 18:03:55 +0530
> > Naresh Kumar Inna <naresh@chelsio.com> wrote:
> > 
> >> This patch contains code for driver initialization, driver resource
> >> allocation and the Work Request module functionality. Driver initialization
> >> includes module entry/exit points, registration with PCI, FC transport and
> >> SCSI mid layer subsystems. The Work Request module provides services for
> >> allocation of DMA queues, posting Work Requests on them and processing
> >> completions.
> >>
> >> Signed-off-by: Naresh Kumar Inna <naresh@chelsio.com>
> > 
> > Although the comments say you are using proc fs, there is no
> > code here related to that.
> 
> I will remove that comment.
> 
> > 
> > Any use of debugfs must be conditional the DEBUG_FS kernel configuration
> > parameter.  Your code probably will break if DEBUG_FS is not
> > enabled.  For a possible alternative see how a sub-config parameter
> > was added in sky2 driver.
> > 
> 
> It appears that debugfs_create_dir() returns an error if DEBUG_FS is not
> enabled. Considering the driver handles this error and continues
> initialization, do you still think I should guard this code within DEBUG_FS?
> 
> Thanks.

That works, just make sure and test it.
