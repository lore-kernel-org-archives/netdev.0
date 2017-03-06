From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] mac80211: Use setup_timer instead of init_timer
Date: Mon, 06 Mar 2017 13:25:04 +0100
Message-ID: <1488803104.5761.6.camel@sipsolutions.net>
References: <20170303124535.30125-1-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        =?UTF-8?Q?Ond=C5=99ej_Lyson=C4=9Bk?= <ondrej.lysonek-9Vj9tDbzfuSlVyrhU4qvOw@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170303124535.30125-1-jslaby-AlSwsSmVLrQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-03-03 at 13:45 +0100, Jiri Slaby wrote:
> From: Ondřej Lysoněk <ondrej.lysonek-9Vj9tDbzfuSlVyrhU4qvOw@public.gmane.org>
> 
> Use setup_timer() and setup_deferrable_timer() to set the data and
> function timer fields. It makes the code cleaner and will allow for
> easier change of the timer struct internals.

Btw, I suspect you generated this with coccinelle and didn't put enough
"..." there, because you missed one in mesh_path_new() :)

Care to send a patch for that one too?

johannes
