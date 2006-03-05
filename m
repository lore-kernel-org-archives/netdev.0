From: Andrew Morton <akpm@osdl.org>
Subject: Re: Discourage duplicate symbols in the kernel? [Was: Intel I/O
 Acc...]
Date: Sun, 5 Mar 2006 01:18:52 -0800
Message-ID: <20060305011852.368c016e.akpm@osdl.org>
References: <20060303214036.11908.10499.stgit@gitlost.site>
	<4408C2CA.5010909@garzik.org>
	<41b516cb0603031439n13e4df4cg8e5b21b606d2b4b8@mail.gmail.com>
	<20060305000933.2d799138.akpm@osdl.org>
	<20060305090251.GA9116@mars.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chris.leech@gmail.com, christopher.leech@intel.com,
	jeff@garzik.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752160AbWCEJUm@vger.kernel.org>
To: Sam Ravnborg <sam@ravnborg.org>
In-Reply-To: <20060305090251.GA9116@mars.ravnborg.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sam Ravnborg <sam@ravnborg.org> wrote:
>
> On Sun, Mar 05, 2006 at 12:09:33AM -0800, Andrew Morton wrote:
>  > > +
>  > > +static inline u8 read_reg8(struct cb_device *device, unsigned int offset)
>  > > +{
>  > > +	return readb(device->reg_base + offset);
>  > > +}
>  > 
>  > These are fairly generic-sounding names.  In fact the as-yet-unmerged tiacx
>  > wireless driver is already using these, privately to
>  > drivers/net/wireless/tiacx/pci.c.
> 
>  Do we in general discourage duplicate symbols even if they are static?

Well, it's a bit irritating that it confuses ctags.  But in this case, one
set is in a header file so the risk of collisions is much-increased.
