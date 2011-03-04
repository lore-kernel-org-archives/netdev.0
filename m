From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [Drbd-dev] [PATCH 2/2 v2] netlink: kill eff_cap from struct
 netlink_skb_parms
Date: Fri, 4 Mar 2011 04:29:56 +0300
Message-ID: <20110304012956.GA13573@ioremap.net>
References: <4D6F6180.5030903@trash.net>
 <20110303173230.GP4988@sequoia.sous-sol.org>
 <20110303.105655.189705829.davem@davemloft.net>
 <20110303201522.GT4988@sequoia.sous-sol.org>
 <20110303223746.GI25069@barkeeper1-xen.linbit>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Chris Wright <chrisw@sous-sol.org>,
	David Miller <davem@davemloft.net>,
	linux-fbdev@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org, dm-devel@redhat.com
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110303223746.GI25069@barkeeper1-xen.linbit>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

On Thu, Mar 03, 2011 at 11:37:46PM +0100, Lars Ellenberg (lars.ellenberg@linbit.com) wrote:
> If so, then this change introduces the possibility for normal users to
> send privileged commands to connector based subsystems, even if they
> may not be able to bind() to suitable sockets to receive any replies.
> 
> Am I missing something?

Yup, connector is very async at that place, but I wonder why the hell I
ever made that decision. I believe we can replace it with pure sync call
of the registered connector callback, since netlink is synchronous and
no one has any problem with it.

-- 
	Evgeniy Polyakov
