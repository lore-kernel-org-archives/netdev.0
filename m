From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: d80211 deadlock with wpa_supplicant and rmmod
Date: Wed, 11 Jul 2007 19:41:53 -0400
Message-ID: <20070711234153.GB5099@tuxdriver.com>
References: <1caff7430707111617o70a534a5x2cf6b611a91f301a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: seventh guardian <seventhguardian-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1caff7430707111617o70a534a5x2cf6b611a91f301a-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 12, 2007 at 12:17:35AM +0100, seventh guardian wrote:
> Hello,
> First of all I'm fairly new to this list (in all, this is my first
> message), so please be gentle.. I promise I will try not to waste your
> precious time.
> 
> >I believe we have a deadlock in d80211.
> 
> I have it too. But I'm using iwl3945 driver, in-kernel mac80211, and a
> gentoo kernel (basically a patched vanilla-2.6.22.1). My machine is a
> x86_64 core 2 duo.
> 
> >The following triggers it on my 2way SMT machine with preempt.
> >
> >modprobe bcm43xx-d80211
> >add sta0
> >ifconfig sta0 up
> >start wpa_supplicant on the interface
> >rmmod bcm43xx-d80211
> >
> >After that rmmod hangs spinning and wpa_supplicant
> >stays in D state.
> >
> >If I first kill wpa_supplicant and then rmmod the module,
> >it does not deadlock.
> 
> I can trigger this way:
> 
> modprobe iwl3945
> ifconfig wlan0 up
> start wpa_supplicant
> do some wpa_supplicant work (for instance issue a scan)
> stop wpa_supplicant
> 
> Then it will deadlock (that is, wpa_supplicant will refuse to be
> killed). The same thing happens if I try to modprobe the module out
> (modprobe will "hang spinning" as you said). I have to ultimately
> hard-shutdown my machine to bring it back to normal.

It seems you are replying to a very old original message.  Since that
message was sent, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org has become the
primary forum for wireless discussion.

Any chance you are savvy enough with git to try the wireless-dev kernel?

        git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-dev.git

Can you replicate the problem using those sources?  If so, you may
want to attach your .config in your reply (just in case the exact
config makes a difference).

Thanks,

John
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
