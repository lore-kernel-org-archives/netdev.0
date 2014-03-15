From: Krishna Chaitanya <chaitanya.mgit@gmail.com>
Subject: Re: [mac80211_hwsim] BUG: unable to handle kernel paging request at ce1db404
Date: Sat, 15 Mar 2014 21:03:54 +0530
Message-ID: <CABPxzYJXQR=t6u33uFT5dU2y6sKK1QhCbBn+t4TmmNfVhNk5gw@mail.gmail.com>
References: <20140305125703.GA7193@localhost> <20140305132317.GB10880@localhost>
 <20140308121138.GA8359@localhost> <20140312173446.GD2983@piware.de>
 <CABPxzYLJA-gQjw2CwmL63dYEQ35h073k_vsp1uEM0B-sAmEwKQ@mail.gmail.com> <1394896841.30941.4.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Martin Pitt <martin.pitt@ubuntu.com>,
	Fengguang Wu <fengguang.wu@intel.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394896841.30941.4.camel@jlt4.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Mar 15, 2014 at 8:50 PM, Johannes Berg
<johannes@sipsolutions.net> wrote:
>
> On Thu, 2014-03-13 at 02:15 +0530, Krishna Chaitanya wrote:
>
> > From the logs it looks like "rate_control_alloc" is failed,
> > causing ieee80211_register_hw to fail triggering the crash.
>
> Yes.
>
> > what RC are u using? Default should be minstrel, i dont see
> > a reason for rc alloc to fail (remote reason kmalloc failure),
> > so did you disable RC completely? No prints either w.r.t RC either in
> > dmesg?
>
> Pay attention to the .config.
>
Missed the attachment, thanks for pointing.
As guessed the rate control is empty causing the registration fail.

CONFIG_MAC80211=y
# CONFIG_MAC80211_RC_PID is not set
# CONFIG_MAC80211_RC_MINSTREL is not set
CONFIG_MAC80211_RC_DEFAULT=""
