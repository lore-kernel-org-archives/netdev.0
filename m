From: Olaf Kirch <okir@suse.de>
Subject: Re: e100 oops on resume
Date: Wed, 25 Jan 2006 13:11:25 +0100
Message-ID: <20060125121125.GH5465@suse.de>
References: <20060124225919.GC12566@suse.de> <20060124232142.GB6174@inferi.kami.home> <20060125090240.GA12651@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751135AbWAYML1@vger.kernel.org>
To: Stefan Seyfried <seife@suse.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060125090240.GA12651@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 25, 2006 at 10:02:40AM +0100, Olaf Kirch wrote:
> I'm not sure what the right fix would be. e100_resume would probably
> have to call e100_alloc_cbs early on, while e100_up should avoid
> calling it a second time if nic->cbs_avail != 0. A tentative patch
> for testing is attached.

Reportedly, the patch fixes the crash on resume.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
