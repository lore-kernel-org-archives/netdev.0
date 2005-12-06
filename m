From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] natsemi: NAPI support
Date: Tue, 6 Dec 2005 01:19:34 +0100
Message-ID: <20051206001934.GA18329@electric-eye.fr.zoreil.com>
References: <20051204224734.GA12962@sirena.org.uk> <20051204231209.GA28949@electric-eye.fr.zoreil.com> <20051205232301.GA4551@sirena.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, Tim Hockin <thockin@hockin.org>,
	Harald Welte <laforge@gnumonks.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751515AbVLFAVg@vger.kernel.org>
To: broonie@sirena.org.uk
Content-Disposition: inline
In-Reply-To: <20051205232301.GA4551@sirena.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Brown <broonie@sirena.org.uk> :
[...]
> I had been under the impression that the stack was supposed to make sure
> that no poll() is running before the driver close() gets called ?

Not exactly. dev_close() waits a bit but it can not be sure that the
device driver will not schedule ->poll() from its irq handler later.

--
Ueimor
