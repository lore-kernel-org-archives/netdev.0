From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC 2/3] genetlink: pass extended error report down
Date: Fri, 07 Apr 2017 21:12:23 +0200
Message-ID: <1491592343.5800.8.camel@sipsolutions.net>
References: <20170407182620.6438-1-johannes@sipsolutions.net>
         <20170407182620.6438-3-johannes@sipsolutions.net>
         <25e1fb8c-22e0-d7a2-13a7-d0def5432c9e@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org
To: Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <25e1fb8c-22e0-d7a2-13a7-d0def5432c9e-my8/4N5VtI7c+919tysfdA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-04-07 at 11:37 -0700, Ben Greear wrote:
> 
> I guess the error string must be constant and always available in
> memory in this implementation?

Yes.

> I think it would be nice to dynamically create strings (malloc,
> snprintf, etc) and have the err_str logic free it when done?

We can think about that later, but I don't actually think it makes a
lot of sense - if we point to the attribute and/or offset you really
ought to have enough info to figure out what's up.

johannes
