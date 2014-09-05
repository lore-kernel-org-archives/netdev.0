From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 5/6] mptsas: use async probe
Date: Fri, 5 Sep 2014 16:16:43 +0900
Message-ID: <20140905071643.GB9323@mtj.dyndns.org>
References: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com>
 <1409899047-13045-6-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gregkh@linuxfoundation.org, dmitry.torokhov@gmail.com,
	falcon@meizu.com, tiwai@suse.de, arjan@linux.intel.com,
	linux-kernel@vger.kernel.org, oleg@redhat.com, hare@suse.com,
	akpm@linux-foundation.org, penguin-kernel@i-love.sakura.ne.jp,
	joseph.salisbury@canonical.com, bpoirier@suse.de,
	santosh@chelsio.com, "Luis R. Rodriguez" <mcgrof@suse.com>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
	Hariprasad S <hariprasad@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>,
	MPT-FusionLinux.pdl@avagotech.com, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1409899047-13045-6-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 04, 2014 at 11:37:26PM -0700, Luis R. Rodriguez wrote:
> From: "Luis R. Rodriguez" <mcgrof@suse.com>
> 
> Its reported that mptsas can at times take over 30 seconds
> to recognize SCSI storage devices [0], this is done on the
> driver's probe path. Use the the new asynch probe to
> circumvent systemd from killing this driver.

Again, *ANY* SCSI storage controller may.  The fact that a specific
bug report was filed on mptsas doesn't really mean anything.

Thanks.

-- 
tejun
