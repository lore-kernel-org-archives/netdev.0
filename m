From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH] compat. ifconf: fix limits
Date: Wed, 8 Mar 2006 17:41:16 -0800
Message-ID: <20060308174116.7cae35e1.rdunlap@xenotime.net>
References: <20060308091608.c56360dd.rdunlap@xenotime.net>
	<20060308.164627.81771250.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Alexandra.Kossovsky@oktetlabs.ru, ak@suse.de, akpm@osdl.org,
	torvalds@osdl.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060308.164627.81771250.davem@davemloft.net>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 08 Mar 2006 16:46:27 -0800 (PST) David S. Miller wrote:

> From: "Randy.Dunlap" <rdunlap@xenotime.net>
> Date: Wed, 8 Mar 2006 09:16:08 -0800
> 
> > From: Randy Dunlap <rdunlap@xenotime.net>
> > 
> > A recent change to compat. dev_ifconf() in fs/compat_ioctl.c
> > causes ifconf data to be truncated 1 entry too early when copying it
> > to userspace.  The correct amount of data (length) is returned,
> > but the final entry is empty (zero, not filled in).
> > The for-loop 'i' check should use <= to allow the final struct
> > ifreq32 to be copied.  I also used the ifconf-corruption program
> > in kernel bugzilla #4746 to make sure that this change does not
> > re-introduce the corruption.
> > 
> > Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
> 
> Good catch, applied.  Thanks Randy.
> 
> Is this one relevant for -stable?

Yes, IMO.  Have to wait for it to be merged upstream, right?

---
~Randy
