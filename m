From: "Luis R. Rodriguez" <mcgrof@suse.com>
Subject: Re: [PATCH v1 5/5] driver-core: add driver asynchronous probe
	support
Date: Fri, 3 Oct 2014 23:12:11 +0200
Message-ID: <20141003211211.GX14081@wotan.suse.de>
References: <1411768637-6809-1-git-send-email-mcgrof@do-not-panic.com> <1411768637-6809-6-git-send-email-mcgrof@do-not-panic.com> <20141003201126.GW14081@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gregkh@linuxfoundation.org, dmitry.torokhov@gmail.com,
	tiwai@suse.de, tj@kernel.org, arjan@linux.intel.com, teg@jklm.no,
	rmilasan@suse.com, werner@suse.com, oleg@redhat.com, hare@suse.com,
	bpoirier@suse.de, santosh@chelsio.com, pmladek@suse.cz,
	dbueso@suse.com, linux-kernel@vger.kernel.org,
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
	Hariprasad S <haripra
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:38416 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750780AbaJCVMQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 17:12:16 -0400
Content-Disposition: inline
In-Reply-To: <20141003201126.GW14081@wotan.suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 03, 2014 at 10:11:26PM +0200, Luis R. Rodriguez wrote:
> On Fri, Sep 26, 2014 at 02:57:17PM -0700, Luis R. Rodriguez wrote:
> > +	queue_work(system_unbound_wq, &priv->attach_work->work);
> 
> Tejun,
> 
> based on my testing so far using system_highpri_wq instead of
> system_unbound_wq yields close to par / better boot times
> than synchronous probe support for all modules. How set are
> you on using system_unbound_wq? About to punt out a new
> series which also addresses built-in.

Nevermind, folks can change this later with better empirical
testing than I can provide and right now the differences I
see are not too conclusive and I suspect we'll see more of
a difference once the right built-in drivers are selected
to probe asynchrounously.

  Luis
