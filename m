From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [PATCH 01/18] ipv4: fix path MTU discovery with connection
 tracking
Date: Mon, 20 Aug 2012 10:04:40 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1208201002270.6101@frira.zrqbmnf.qr>
References: <1345434006-16549-1-git-send-email-kaber@trash.net> <1345434006-16549-2-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1345434006-16549-2-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 2012-08-20 05:39, Patrick McHardy wrote:

>IPv4 conntrack defragments incoming packet at the PRE_ROUTING hook and
>(in case of forwarded packets) refragments them at POST_ROUTING
>independant of the IP_DF flag.

"independent". (also in 06/18)
