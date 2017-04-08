From: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: Re: [PATCH 4/5] netlink: pass extended ACK struct to parsing
 functions
Date: Sat, 8 Apr 2017 14:50:09 -0400
Message-ID: <3077bf17-553d-f9e3-8873-c59fbb26e2aa@cumulusnetworks.com>
References: <20170408174900.12820-1-johannes@sipsolutions.net>
 <20170408174900.12820-5-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>,
        Jiri Benc <jbenc-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170408174900.12820-5-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 4/8/17 1:48 PM, Johannes Berg wrote:
> From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> 
> Pass the new extended ACK reporting struct to all of the
> generic netlink parsing functions. For now, pass NULL in
> almost all callers (except for some in the core.)
> 
> Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

fails to compile as well:

In file included from /home/dsa/kernel-4.git/net/sched/cls_rsvp.c:27:0:
/home/dsa/kernel-4.git/net/sched/cls_rsvp.h: In function ‘rsvp_change’:
/home/dsa/kernel-4.git/net/sched/cls_rsvp.h:487:8: error: too few
arguments to function ‘nla_parse_nested’
  err = nla_parse_nested(tb, TCA_RSVP_MAX, opt, rsvp_policy);
        ^
In file included from /home/dsa/kernel-4.git/include/net/rtnetlink.h:5:0,
                 from /home/dsa/kernel-4.git/include/net/sch_generic.h:12,
                 from /home/dsa/kernel-4.git/include/linux/filter.h:20,
                 from /home/dsa/kernel-4.git/include/net/sock.h:64,
                 from /home/dsa/kernel-4.git/include/net/inet_sock.h:27,
                 from /home/dsa/kernel-4.git/include/net/ip.h:30,
                 from /home/dsa/kernel-4.git/net/sched/cls_rsvp.c:18:
/home/dsa/kernel-4.git/include/net/netlink.h:754:19: note: declared here
 static inline int nla_parse_nested(struct nlattr *tb[], int maxtype,
