From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH iproute2] vxlan: allow specifying multiple default
 destinations
Date: Thu, 30 May 2013 16:57:19 +0100
Message-ID: <20130530155719.GD10532@casper.infradead.org>
References: <1369821617-29098-1-git-send-email-mike.rapoport@ravellosystems.com>
 <1369821617-29098-4-git-send-email-mike.rapoport@ravellosystems.com>
 <ko4kcr$h8j$1@ger.gmane.org>
 <CAF1J0HPDAkhAybQt-tOFLLTLzaXiWy_TSbFF2FT3PMaXbnxJuw@mail.gmail.com>
 <20130529155625.2ee5f6bb@nehalam.linuxnetplumber.net>
 <CAF1J0HNiBED=BLHqPPk8w2=DDvSWdZwMPvtag6rpPhxnboT4GA@mail.gmail.com>
 <20130530114424.GC10532@casper.infradead.org>
 <20130530124652.GA29547@zed.ravello.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Mike Rapoport <mike.rapoport@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:44640 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933729Ab3E3P5U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 11:57:20 -0400
Content-Disposition: inline
In-Reply-To: <20130530124652.GA29547@zed.ravello.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/30/13 at 03:46pm, Mike Rapoport wrote:
> I'm feeling Ok about "ip link set [..] dstadd/dstdel". What does bother
> me is that you can't have different parameters for "ip link add" and "ip
> link set" for vxlan (and other iplink) utility. So, one can use
> ip link add [..] dstdel
> which does not make sense...

You can easily pass an additional argument into iplink_modify()
and exclude certain options in the "add" use case.
