From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [PATCH v3 1/3] init / kthread: add module_long_probe_init() and module_long_probe_exit()
Date: Mon, 18 Aug 2014 23:11:10 -0500
Message-ID: <CAB=NE6VADPpBDDrbb1jsNEr=QEbRUMOxo=bBa9S+4W0ybDQz3w@mail.gmail.com>
References: <20140816025007.GB3347@wotan.suse.de> <s5h1tsfwqi2.wl-tiwai@suse.de>
 <20140817122527.GA30546@redhat.com> <20140817124803.GA31996@redhat.com>
 <20140817125505.GA32429@redhat.com> <20140817174624.GE3347@wotan.suse.de>
 <20140817182138.GA4411@redhat.com> <s5hfvguw570.wl-tiwai@suse.de>
 <20140818122217.GA12707@redhat.com> <s5ha97253yo.wl-tiwai@suse.de> <20140818151954.GA20284@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Takashi Iwai <tiwai@suse.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Joseph Salisbury <joseph.salisbury@canonical.com>,
	Kay Sievers <kay@vrfy.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Benjamin Poirier <bpoirier@suse.de>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@avagotech.com>,
	Sreekanth Reddy <sreekanth.reddy@avagotech.com>,
	Abhijit Mahajan <abhijit.mahajan@avagotech.com>,
	Hariprasad S <hariprasad@chelsio.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	MPT-FusionLinux.pdl@avagotech.com,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	"netdev
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140818151954.GA20284@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 18, 2014 at 10:19 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> And, again, I do not really know which version is better.

In Chicago right now -- feedback was it seems the that generally
splitting up probe from init might be good in the end, if we do this
we won't need a work around for drivers that wait until our
grandmothers die on probe, but we certainly will then be penalizing
drivers who's init does take over 30 seconds. I'm waiting to see an
alternative version of the solution provided as an example on the
other thread, maybe it will fix my keyboard issue :)

 Luis
