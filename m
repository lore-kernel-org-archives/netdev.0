From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH 2/2] Add a netlink attribute INET_DIAG_SECCTX
Date: Thu, 01 Sep 2011 08:28:10 -0400
Message-ID: <1971656.b979ahlREa@sifl>
References: <1314779777-12669-1-git-send-email-rongqing.li@windriver.com> <2593215.lUI7et83Qv@sifl> <4E5F5153.6070708@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org
To: Rongqing Li <rongqing.li@windriver.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <4E5F5153.6070708@windriver.com>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, September 01, 2011 05:33:07 PM Rongqing Li wrote:
> On 09/01/2011 05:18 AM, Paul Moore wrote:
> > On Wednesday, August 31, 2011 04:36:17 PM rongqing.li@windriver.com wrote:
> >> From: Roy.Li<rongqing.li@windriver.com>
> >> 
> >> Add a new netlink attribute INET_DIAG_SECCTX to dump the security
> >> context of TCP sockets.
> > 
> > You'll have to forgive me, I'm not familiar with the netlink code used
> > by
> > netstat and friends, but is there anyway to report back the security
> > context of UDP sockets?  Or does the code below handle that already?
> > 
> > In general, AF_INET and AF_INET6 sockets, regardless of any upper level
> > protocols, have security contexts associated with them and it would be
> > nice to see them in netstat.
> 
> Yes, this is real concern, If the dumping tcp security context can be
> accepted by netdev, I am planning to implement it for ipv4 udp socket, unix
> socket. then ipv6..

Great, I'm glad to hear you're planning on implementing this for more than 
just TCP.

I understand your desire to have the basic idea accepted with only TCP 
implemented - and that is fine with me - but I would like to see support for 
all of the protocols merged at the same time.  In other words, seeking the 
basic ACKs for TCP from the davem, et al is okay but I'd like to defer merging 
TCP support until you have everything implemented and ready to be merged.

-- 
paul moore
www.paul-moore.com

