From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 7/7] driver-core: add preferred async probe option for
 built-in and modules
Date: Mon, 6 Oct 2014 16:19:26 -0400
Message-ID: <20141006201926.GF18303@htj.dyndns.org>
References: <1412372683-2003-1-git-send-email-mcgrof@do-not-panic.com>
 <1412372683-2003-8-git-send-email-mcgrof@do-not-panic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gregkh@linuxfoundation.org, dmitry.torokhov@gmail.com,
	tiwai@suse.de, arjan@linux.intel.com, teg@jklm.no,
	rmilasan@suse.com, werner@suse.com, oleg@redhat.com, hare@suse.com,
	bpoirier@suse.de, santosh@chelsio.com, pmladek@suse.cz,
	dbueso@suse.com, mcgrof@suse.com, linux-kernel@vger.kernel.org,
	Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
	Casey Leedom <leedom@chelsio.com>,
	Hariprasad S <harip
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1412372683-2003-8-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Luis.

The patchset generally looks good to me.  Please feel free to add

 Reviewed-by: Tejun Heo <tj@kernel.org>

A question below.

On Fri, Oct 03, 2014 at 02:44:43PM -0700, Luis R. Rodriguez wrote:
> +	bus.enable_kern_async=1 [KNL]
> +			This tells the kernel userspace has been vetted for
> +			asynchronous probe support and can listen to the device
> +			driver prefer_async_probe flag for both built-in device
> +			drivers and modules.

Do we intend to keep this param permanently?  Isn't this more of a
temp tool to be used during development?  If so, maybe we should make
that clear with __DEVEL__ too?

Thanks.

-- 
tejun
