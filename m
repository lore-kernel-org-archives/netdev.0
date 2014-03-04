From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC v3 0/6] networking: address root block upon initialization
Date: Mon, 3 Mar 2014 17:44:16 -0800
Message-ID: <20140303174416.2240ec9f@nehalam.linuxnetplumber.net>
References: <1393886825-24323-1-git-send-email-mcgrof@do-not-panic.com>
	<CAB=NE6XLe0jkMTP=SkFDhMaWiubHTj7zyJwbbOcoCkkhYpBpdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kvm@vger.kernel.org, xen-devel@lists.xenproject.org
To: "Luis R. Rodriguez" <mcgrof@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAB=NE6XLe0jkMTP=SkFDhMaWiubHTj7zyJwbbOcoCkkhYpBpdA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 3 Mar 2014 17:05:18 -0800
"Luis R. Rodriguez" <mcgrof@suse.com> wrote:

> On Mon, Mar 3, 2014 at 2:46 PM, Luis R. Rodriguez
> <mcgrof@do-not-panic.com> wrote:
> > From: "Luis R. Rodriguez" <mcgrof@suse.com>
> 
> <-- snip -->
> 
> > As I tested using the root block preference I noticed that if a net_device
> > slave under the bridge gets the designated root port prior to setting in
> > userspace the root_block feature enabling the feature won't kick the
> > bridge to remove that net_device from the designated port. I addressed
> > that issue and also upkeeping the initial random MAC address given to
> > the bridge as if othwerwise we'd end up with a zero MAC address bridge
> > if we root block all ports. I have only done local tests I'd appreciate a
> > bit more wide test coverage and review.
> 
> 
> Stephen,
> 
> I should note that even if we discard patches 4-6 patches for an
> alternative implementation patches 1-3 should still be applicable for
> review. Let me know what you think of those.
> 
>   Luis
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

I agree with 0-3 as normal improvements.
