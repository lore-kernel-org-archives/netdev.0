From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Sat, 6 Sep 2014 07:57:32 +0900
Message-ID: <20140905225732.GF15723@mtj.dyndns.org>
References: <1409899047-13045-1-git-send-email-mcgrof@do-not-panic.com>
 <CAB=NE6Wti1RpAFk5q_YeZn2F9Rd=wsiwhyPszu74nG9fXwH5vQ@mail.gmail.com>
 <20140905141241.GC10455@mtj.dyndns.org>
 <20140905164405.GA28964@core.coreip.homeip.net>
 <20140905174925.GA12991@mtj.dyndns.org>
 <20140905181003.GA29003@core.coreip.homeip.net>
 <20140905222956.GA15723@mtj.dyndns.org>
 <540A3CF4.5070508@linux.intel.com>
 <20140905225248.GC35667@core.coreip.homeip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@linux.intel.com>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Wu Zhangjin <falcon@meizu.com>, Takashi Iwai <tiwai@suse.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Oleg Nesterov <oleg@redhat.com>, hare@suse.com,
	Andrew Morton <akpm@linux-foundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Benjamin Poirier <bpoirier@suse.de>,
	Santosh Rastapur <santosh@chelsio.com>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit
To: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140905225248.GC35667@core.coreip.homeip.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Fri, Sep 05, 2014 at 03:52:48PM -0700, Dmitry Torokhov wrote:
> Ahem... and they sure it works reliably with large storage arrays? With
> SCSI doing probing asynchronously already?

I believe this has been mentioned before too but, yes, SCSI device
probing is asynchronous and parallelized but the registration of the
discovered devices are fully serialized according to driver attach
order.  Storage devices are probed in parallel and attached in a fully
deterministic order.  That part has never changed.

Thanks.

-- 
tejun
