From: Olaf Kirch <okir@suse.de>
Subject: Re: e100 oops on resume
Date: Thu, 26 Jan 2006 20:09:57 +0100
Message-ID: <20060126190957.GB32622@suse.de>
References: <20060124225919.GC12566@suse.de> <20060124232142.GB6174@inferi.kami.home> <20060125090240.GA12651@suse.de> <20060125121125.GH5465@suse.de> <4807377b0601251137r7621216byc47b03a3c634557c@mail.gmail.com> <4807377b0601251628k4227dad0ld731f2c25c211b91@mail.gmail.com> <20060126190236.GA12481@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964802AbWAZTKA@vger.kernel.org>
To: Stefan Seyfried <seife@suse.de>
Content-Disposition: inline
In-Reply-To: <20060126190236.GA12481@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 26, 2006 at 08:02:37PM +0100, Stefan Seyfried wrote:
> Will be in the next SUSE betas, so if anything breaks, we'll notice
> it.

I doubt it. As Jesse mentioned, e100_hw_init is called from e100_up,
so the call from e100_resume was really superfluous.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
