From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 01/18] ipv4: fix path MTU discovery with connection
 tracking
Date: Mon, 20 Aug 2012 12:59:45 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208201259390.24912@stinky-local.trash.net>
References: <1345434006-16549-1-git-send-email-kaber@trash.net>
 <1345434006-16549-2-git-send-email-kaber@trash.net>
 <alpine.LNX.2.01.1208201002270.6101@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@inai.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1208201002270.6101@frira.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Aug 2012, Jan Engelhardt wrote:

> On Monday 2012-08-20 05:39, Patrick McHardy wrote:
>
>> IPv4 conntrack defragments incoming packet at the PRE_ROUTING hook and
>> (in case of forwarded packets) refragments them at POST_ROUTING
>> independant of the IP_DF flag.
>
> "independent". (also in 06/18)

Fixed, thanks.
