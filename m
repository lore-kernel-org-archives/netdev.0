From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: [RFC] back on nf_tables (plus compatibility layer)
Date: Thu, 1 Nov 2012 16:49:01 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1210311726400.20723@nerf07.vanv.qr>
References: <20121025170632.GA4890@1984> <alpine.LNX.2.01.1210252352420.13437@nerf07.vanv.qr> <20121026110419.GA16629@1984> <alpine.LNX.2.01.1210311449570.29232@nerf07.vanv.qr> <20121031154216.GB9558@1984>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Netfilter Development Mailing list
	<netfilter-devel@vger.kernel.org>,
	Linux Networking Developer Mailing List
	<netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20121031154216.GB9558@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 2012-10-31 16:42, Pablo Neira Ayuso wrote:
>> >> 
>> >> I have updated to the newest tree, and the first set is
>> >> available in the git repository at:
>> >>   git://git.inai.de/linux xt2-20121025
>> >
>> >If you think this feature is important, checkout nf_tables and think
>> >how to integrate this prototype code that provides atomic table
>> >replacement to it.
>> 
>> I'd rather tinker with xt2.
>
>You're are free spend your time on your pet project, but I warn you:
>it will *extremely hard* to justify its inclusion into mainline.
>As said, I don't think it makes sense to add two firewall
>engines/interfaces for the same thing.

You make it sound like you have already made up your mind and will
not consider xtnl because you are having nft as your pet project.
That would be really sad.

So, what xt2 has of this hour.

(- netlink interface obviously)
 - netns support
 - single table sufficiency
 - is RCU'd
 - atomic whole-table replace
 - atomic chain-level multi-rule replace
   (less to transfer over netlink between kernel<->user)
 - chain-level dump (also relates to transfer size)
 - packed ruleset for cache efficiency
 - already has had some review from community members when it was last posted
 - in-code and external documentation

Certainly there is still something to do - but so would there be for nft.
