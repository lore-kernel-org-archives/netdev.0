From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Sat, 6 Sep 2014 08:32:03 +0900
Message-ID: <20140905233203.GG15723@mtj.dyndns.org>
References: <CAB=NE6Wti1RpAFk5q_YeZn2F9Rd=wsiwhyPszu74nG9fXwH5vQ@mail.gmail.com>
 <20140905141241.GC10455@mtj.dyndns.org>
 <20140905164405.GA28964@core.coreip.homeip.net>
 <20140905174925.GA12991@mtj.dyndns.org>
 <20140905181003.GA29003@core.coreip.homeip.net>
 <20140905222956.GA15723@mtj.dyndns.org>
 <20140905223139.GB15723@mtj.dyndns.org>
 <20140905224917.GB35667@core.coreip.homeip.net>
 <20140905225533.GE15723@mtj.dyndns.org>
 <20140905232242.GE35667@core.coreip.homeip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Wu Zhangjin <falcon@meizu.com>, Takashi Iwai <tiwai@suse.de>,
	Arjan van de Ven <arjan@linux.intel.com>,
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
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140905232242.GE35667@core.coreip.homeip.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey,

On Fri, Sep 05, 2014 at 04:22:42PM -0700, Dmitry Torokhov wrote:
> > I don't get it.  This is a behavior userland already depends on for
> > boots.  What's there to agree or disagree?  This is just a fact that
> > we can't do this w/o disturbing some userlands in a major way.
> 
> I am just expressing my disbelief that somebody relies on module loading
> being synchronous with probing. Out of curiosity, do you have any
> pointers?

I've seen initrd scripts which depended on the behavior to wait for
storage devices over the years.  AFAIK, none of the modern distros
does it but this has been such a basic feature all along and it seems
highly unlikely to me that there's no userland remaining out there
depending on such behavior.  We do have a lot of different userlands,
many of them quite ad-hoc.

Thanks.

-- 
tejun
