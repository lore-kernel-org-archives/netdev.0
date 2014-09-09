From: Dmitry Torokhov <dmitry.torokhov@gmail.com>
Subject: Re: [RFC v2 3/6] kthread: warn on kill signal if not OOM
Date: Tue, 09 Sep 2014 16:01:32 -0700
Message-ID: <5762134.BLS0EbmNJd@dtor-glaptop>
References: <20140905174925.GA12991@mtj.dyndns.org> <20140909224143.GB3154@mtj.dyndns.org> <1410302783.13298.50.camel@jarvis.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Tejun Heo <tj@kernel.org>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	Lennart Poettering <lennart@poettering.net>,
	Kay Sievers <kay@vrfy.org>,
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
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>,
	Tim Gardner <tim.gardner@canonical.com>,
	Pierre Fersing <pierre-fersing@pierref.org>,
	Nagalakshmi Nandigama <nagalakshmi.nandigama@avagotech.com>,
	Praveen Krishnamoorthy <praveen.krishnamoorthy@a
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410302783.13298.50.camel@jarvis.lan>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday, September 09, 2014 03:46:23 PM James Bottomley wrote:
> On Wed, 2014-09-10 at 07:41 +0900, Tejun Heo wrote:
> > 
> > The thing is that we have to have dynamic mechanism to listen for
> > device attachments no matter what and such mechanism has been in place
> > for a long time at this point.  The synchronous wait simply doesn't
> > serve any purpose anymore and kinda gets in the way in that it makes
> > it a possibly extremely slow process to tell whether loading of a
> > module succeeded or not because the wait for the initial round of
> > probe is piggybacked.
> 
> OK, so we just fire and forget in userland ... why bother inventing an
> elaborate new infrastructure in the kernel to do exactly what
> 
> modprobe <mod> &
> 
> would do?

Just so we do not forget: we also want the no-modules case to also be able
to probe asynchronously so that a slow device does not stall kernel booting.

Thanks.

-- 
Dmitry
