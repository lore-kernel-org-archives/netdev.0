From: Pete Zaitcev <zaitcev@redhat.com>
Subject: Re: wireless: recap of current issues (stack)
Date: Sat, 14 Jan 2006 20:42:11 -0800
Message-ID: <20060114204211.72942d45.zaitcev@redhat.com>
References: <20060113195723.GB16166@tuxdriver.com>
	<20060113212605.GD16166@tuxdriver.com>
	<20060113213200.GG16166@tuxdriver.com>
	<Pine.LNX.4.58.0601141448480.5587@p15091797.pureserver.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, zaitcev@redhat.com, <dsd@gentoo.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751125AbWAOEmf@vger.kernel.org>
To: Ulrich Kunitz <kune@deine-taler.de>
In-Reply-To: <Pine.LNX.4.58.0601141448480.5587@p15091797.pureserver.info>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 14 Jan 2006 15:13:39 +0100 (CET), Ulrich Kunitz <kune@deine-taler.de> wrote:

> [...] Register accesses in USB devices should be
> able to sleep. However the 80211 stacks I've seen so far have a
> fixed set of capabilities and do also assume, that at the driver
> layer everything can be done in atomic mode, which is only true
> for buses that support memory-mapping.

If this problem is real, then it's serious. However, I'm not seeing it
with prism54usb and Berg's softmac (yet?). Would you be so kind to provide
the file name and function name for the code which makes these assumptions?

Thanks,
-- Pete
