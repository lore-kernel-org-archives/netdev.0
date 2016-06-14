From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [very-RFC 0/8] TSN driver for the kernel
Date: Tue, 14 Jun 2016 12:18:44 +0100
Message-ID: <20160614121844.54a125a5@lxorguk.ukuu.org.uk>
References: <1465686096-22156-1-git-send-email-henrik@austad.us>
	<20160613114713.GA9544@localhost.localdomain>
	<20160613195136.GC2441@netboy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Henrik Austad <henrik@austad.us>, linux-kernel@vger.kernel.org,
	linux-media@vger.kernel.org, alsa-devel@vger.kernel.org,
	netdev@vger.kernel.org, henrk@austad.us,
	Arnd Bergmann <arnd@linaro.org>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160613195136.GC2441@netboy>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 13 Jun 2016 21:51:36 +0200
Richard Cochran <richardcochran@gmail.com> wrote:

> On Mon, Jun 13, 2016 at 01:47:13PM +0200, Richard Cochran wrote:
> > 3. ALSA support for tunable AD/DA clocks.  The rate of the Listener's
> >    DA clock must match that of the Talker and the other Listeners.
> >    Either you adjust it in HW using a VCO or similar, or you do
> >    adaptive sample rate conversion in the application. (And that is
> >    another reason for *not* having a shared kernel buffer.)  For the
> >    Talker, either you adjust the AD clock to match the PTP time, or
> >    you measure the frequency offset.  
> 
> Actually, we already have support for tunable clock-like HW elements,
> namely the dynamic posix clock API.  It is trivial to write a driver
> for VCO or the like.  I am just not too familiar with the latest high
> end audio devices.

Why high end ? Even the most basic USB audio is frame based and
isosynchronous to the USB clock. It also reports back the delay
properties.

Alan
