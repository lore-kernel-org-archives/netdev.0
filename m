From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] netdev_ops
Date: Fri, 11 Jul 2003 13:07:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F0F18EB.9020609@candelatech.com>
References: <20030708163042.GL23597@parcelfarce.linux.theplanet.co.uk> <3F0B2D30.4020102@candelatech.com> <20030708212551.GL1939@parcelfarce.linux.theplanet.co.uk> <20030708.150835.78728697.davem@redhat.com> <20030709161520.GW1939@parcelfarce.linux.theplanet.co.uk> <20030711193215.GH16037@gtf.org> <3F0F153C.4040506@candelatech.com> <20030711195856.GB30449@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matthew Wilcox <willy@debian.org>, netdev@oss.sgi.com,
   "David S. Miller" <davem@redhat.com>,
   Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20030711195856.GB30449@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:

> Regardless, addressing your point, I consider ethtool.h a
> kernel-internal header, that's why it uses internal kernel types.
> Anybody who copies it to userspace must deal with that.  It is _not_
> intended to be #included directly from userspace.  ethtool (the userland
> program) purposefully does its own typedefs and stuff.

Any particular reason to not include it directly?  It seems no more
likely to cause problems than to use some potentially out-of-date
copy in user-space.  (And it might make the compile slightly tougher
if you are distributing primarily as source.)

Ben

-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
