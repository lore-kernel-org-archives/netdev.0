From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH] mac80211: Fix clang warning about constant operand in
 logical operation
Date: Thu, 06 Apr 2017 21:11:18 +0200
Message-ID: <1491505878.11399.4.camel@sipsolutions.net>
References: <20170406185633.91065-1-mka@chromium.org>
         (sfid-20170406_205658_084798_12B3FAFB)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Grant Grundler <grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Michael Davidson <md-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Greg Hackmann <ghackmann-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
To: Matthias Kaehlcke <mka-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170406185633.91065-1-mka-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> (sfid-20170406_205658_084798_12B3FAFB)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-04-06 at 11:56 -0700, Matthias Kaehlcke wrote:
> Clang raises a warning about the expression 'strlen(CONFIG_XXX)'
> being
> used in a logical operation. Clangs' builtin strlen function resolves
> the
> expression to a constant at compile time, which causes clang to
> generate
> a 'constant-logical-operand' warning.
> 
> Split the if statement in two to avoid using the const expression in
> a logical operation.
> 
I don't really see all much point in doing this for the warning's
sake... hopefully it doesn't actually generate worse code, but I think
the code ends up looking worse and people will forever wonder what the
goto is really doing there.

johannes
