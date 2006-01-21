From: Lee Revell <rlrevell@joe-job.com>
Subject: Re: My vote against eepro* removal
Date: Fri, 20 Jan 2006 20:30:48 -0500
Message-ID: <1137807048.3241.58.camel@mindpipe>
References: <AAD6DA242BC63C488511C611BD51F367323324@MAILIT.keba.co.at>
	 <20060120095548.GA16000@2ka.mipt.ru> <1137804050.3241.32.camel@mindpipe>
	 <56a8daef0601201719t448a6177lfebabe3ca38a00c7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	kus Kusche Klaus <kus@keba.com>,
	Adrian Bunk <bunk@stusta.de>, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, ganesh.venkatesan@intel.com,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964776AbWAUBaw@vger.kernel.org>
To: John Ronciak <john.ronciak@gmail.com>
In-Reply-To: <56a8daef0601201719t448a6177lfebabe3ca38a00c7@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-01-20 at 17:19 -0800, John Ronciak wrote:
> On 1/20/06, Lee Revell <rlrevell@joe-job.com> wrote:
> > Seems like the important question is, why does e100 need a watchdog if
> > eepro100 works fine without one?  Isn't the point of a watchdog in this
> > context to work around other bugs in the driver (or the hardware)?
> There are a number of things that the watchdog in e100 does.  It
> checks link (up, down), reads the hardware stats, adjusts the adaptive
> IFS and checks to 3 known hang conditions based on certain types of
> the hardware.  You might be able to get around without doing the
> work-arounds (as long as you don't' see hangs happening with the
> hardware being used) but the checking of the link and the stats are
> probably needed.

Why don't these cause excessive scheduling delays in eepro100 then?
Can't we just copy the eepro100 behavior?

Lee
