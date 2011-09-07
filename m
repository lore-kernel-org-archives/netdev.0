From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: re add support for bcm5750
Date: Tue, 6 Sep 2011 18:25:15 -0700
Message-ID: <20110907012515.GA9038@mcarlson.broadcom.com>
References: <1280784368-4226-8-git-send-email-mcarlson@broadcom.com>
 <20110906170343.09252578@schatten.dmk.lab>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Benjamin Li" <benli@broadcom.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Francesco Piccinno" <stack.box@gmail.com>
To: "Florian Mickler" <florian@mickler.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110906170343.09252578@schatten.dmk.lab>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 06, 2011 at 08:03:43AM -0700, Florian Mickler wrote:
> Hi,
> 
> in https://bugzilla.kernel.org/show_bug.cgi?id=42132 Francesco wrote: 
> 
> > I have a notebook (HP TC4400) which has a BCM5750 ethernet card inside. The
> > ouput of lspci is:
> > 
> > 08:00.0 Ethernet controller [0200]: Broadcom Corporation NetXtreme BCM5750M
> > Gigabit Ethernet [14e4:167c]
> > 
> > Commit 67b284d476bcb3d100e946da23d6cf9acfd0465c removed the support for this
> > device. I wish to have the support for this network card back again. Thanks!

Hi Florian.  Are you experiencing the same problem?  We found that
Francesco's problem was that the firmware of his device was missing.  Do
you see :

eth0: No firmware running

messages?
