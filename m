From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [FAILED COMPILE v4.3-rc2] conntrack.c:316: undefined reference to `nf_ct_frag6_gather'
Date: Tue, 22 Sep 2015 15:16:27 -0700
Message-ID: <CANr6G5y92P17C7kzJVyF3GNO-Tprq79NzMPpHf_8WsPQPYOqiQ@mail.gmail.com>
References: <20150922180517.6e928292@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Justin Pettit <jpettit@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Thomas Graf <tgraf@suug.ch>,
	Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:36078 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759779AbbIVWQr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 18:16:47 -0400
Received: by ykdt18 with SMTP id t18so24601415ykd.3
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 15:16:46 -0700 (PDT)
In-Reply-To: <20150922180517.6e928292@gandalf.local.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22 September 2015 at 15:05, Steven Rostedt <rostedt@goodmis.org> wrote:
>
> The attached config gives the following error:
>
> net/built-in.o: In function `handle_fragments':
> net/openvswitch/conntrack.c:316: undefined reference to `nf_ct_frag6_gather'
> Makefile:916: recipe for target 'vmlinux' failed
>
> -- Steve

commit 38c089d "openvswitch: Fix dependency on IPv6 defrag." on dave's
net tree fixes this.
