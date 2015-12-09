From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Wed, 9 Dec 2015 02:40:38 +0100
Message-ID: <20151209014038.GA19097@pox.localdomain>
References: <20151201154445.GF29497@tuxdriver.com>
 <1448984968.3382143.454794705.68D88B7D@webmail.messagingengine.com>
 <CALx6S36i7Ee3Njs6OPVndyoGz1OpYss3YRPG8KO2ehxvAe50dA@mail.gmail.com>
 <1449074114.3806253.455834737.16948E5F@webmail.messagingengine.com>
 <CALx6S34Zqn1t4RPkAoa3QT-vWLvawnBN19qEZ12P-YiCEckxHw@mail.gmail.com>
 <565F8059.3010101@gmail.com>
 <CALx6S35EwSXNvOxf_a+=5n2xBN6ZTq--cxdciNgCzPnqzxACJA@mail.gmail.com>
 <566687DC.7040805@gmail.com>
 <5666E7EB.40709@mojatatu.com>
 <5666F2DB.5000101@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.fastabend@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jesse Gross <jesse@kernel.org>,
	David Miller <davem@davemloft.net>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:37312 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752037AbbLIBkm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 20:40:42 -0500
Received: by wmww144 with SMTP id w144so52812891wmw.0
        for <netdev@vger.kernel.org>; Tue, 08 Dec 2015 17:40:40 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <5666F2DB.5000101@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/08/15 at 10:10am, Jamal Hadi Salim wrote:
> On 15-12-08 09:23 AM, Jamal Hadi Salim wrote:
> >On 15-12-08 02:33 AM, John Fastabend wrote:
> 
> >;-> I feel a little vindicated with this discussion.
> >
> >Of course you can implement hardware using BPF!
> 
> BTW - Just to be clear; I am not arguing for what that paper
> preaches. What the paper preaches is an academic exercise
> (square hole, round peg - must fit into OF description).
> What i am saying is you can take the ebpf instruction set and
> create a cpu that executes those instructions.

I'm still having a difficulty trying to understand what exactly
the intended proposal around this is. You may have just answered
my question but just to make sure: When people refer to
implementing or interpreting BPF in hardware, do they mean:

 1) A limited BPF instruction set used as descriptive language
    to define match/action logic?
 2) A specific (versioned) BPF instruction set which hardware
    can support?
 3) The full BPF instruction set of the current kernel + all
    defined helper functions and tail call support?

Would programs of 2) and 3) nature be simply rejected or would
the driver convert them somehow?
