From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Wed, 9 Dec 2015 23:03:39 +0100
Message-ID: <20151209220339.GD11201@pox.localdomain>
References: <CALx6S34Zqn1t4RPkAoa3QT-vWLvawnBN19qEZ12P-YiCEckxHw@mail.gmail.com>
 <565F8059.3010101@gmail.com>
 <CALx6S35EwSXNvOxf_a+=5n2xBN6ZTq--cxdciNgCzPnqzxACJA@mail.gmail.com>
 <566687DC.7040805@gmail.com>
 <5666E7EB.40709@mojatatu.com>
 <5666F2DB.5000101@mojatatu.com>
 <20151209014038.GA19097@pox.localdomain>
 <20151209054543.GA7902@ast-mbp.thefacebook.com>
 <20151209125857.GA9900@pox.localdomain>
 <20151209173842.GA18097@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jesse Gross <jesse@kernel.org>,
	David Miller <davem@davemloft.net>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37719 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902AbbLIWDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 17:03:42 -0500
Received: by wmww144 with SMTP id w144so222199wmw.0
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 14:03:41 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20151209173842.GA18097@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/09/15 at 09:38am, Alexei Starovoitov wrote:
> On Wed, Dec 09, 2015 at 01:58:57PM +0100, Thomas Graf wrote:
> > 
> > So if the goal is to make the intent available to the hardware in
> > a format which both the kernel and the hardware can draw the same
> > conclusions from, wouldn't something like P4 + BPF derived from P4
> > be a possibly better fit? There is discussion on stateful P4
> > processing now.
> 
> p4 is a high level language and absolutely not suitable for such purpose.
> bpf as intermediate representation can be generated from p4 or C or other
> language. There is room to innovate in the language definition on top
> and in HW design at the bottom. That's the most flexible model.

If you don't want to discuss it, no problem. But stating that P4
is a high level language (not sure what this means exactly since
we exactly _want_ an abstraction away from hardware) and that it's
not suitable for this purpose is just wrong. P4 has been created
exactly for the purpose of expressing how a packet should be
processed by a forwarding element independent of specific hardware.

There is a lot of interesting open source work coming out of that
space and I think we owe it to at least consider P4. The goal is
very much in line with what we want to achieve as Linux community
as well.

I'll wait for your proposal as you stated you are working on
something specific.
