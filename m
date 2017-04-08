From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 4/5] netlink: pass extended ACK struct to parsing
 functions
Date: Sat, 08 Apr 2017 22:15:11 +0200
Message-ID: <1491682511.2379.2.camel@sipsolutions.net>
References: <20170408174900.12820-1-johannes@sipsolutions.net>
         <20170408174900.12820-5-johannes@sipsolutions.net>
         <3077bf17-553d-f9e3-8873-c59fbb26e2aa@cumulusnetworks.com>
         (sfid-20170408_205014_016171_8149213D)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
        Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org
To: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <3077bf17-553d-f9e3-8873-c59fbb26e2aa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org> (sfid-20170408_205014_016171_8149213D)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, 2017-04-08 at 14:50 -0400, David Ahern wrote:
> On 4/8/17 1:48 PM, Johannes Berg wrote:
> > From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> > 
> > Pass the new extended ACK reporting struct to all of the
> > generic netlink parsing functions. For now, pass NULL in
> > almost all callers (except for some in the core.)
> > 
> > Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> 
> fails to compile as well:
> 
> In file included from /home/dsa/kernel-
> 4.git/net/sched/cls_rsvp.c:27:0:
> /home/dsa/kernel-4.git/net/sched/cls_rsvp.h: In function
> ‘rsvp_change’:
> /home/dsa/kernel-4.git/net/sched/cls_rsvp.h:487:8: error: too few
> arguments to function ‘nla_parse_nested’
>   err = nla_parse_nested(tb, TCA_RSVP_MAX, opt, rsvp_policy);
>         ^

Yeah, spatch misses header files without special command-line arguments
... this should be fixed in v2, the kbuild bot also noticed it.

johannes
