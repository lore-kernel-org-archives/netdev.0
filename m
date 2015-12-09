From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Wed, 9 Dec 2015 09:38:44 -0800
Message-ID: <20151209173842.GA18097@ast-mbp.thefacebook.com>
References: <1449074114.3806253.455834737.16948E5F@webmail.messagingengine.com>
 <CALx6S34Zqn1t4RPkAoa3QT-vWLvawnBN19qEZ12P-YiCEckxHw@mail.gmail.com>
 <565F8059.3010101@gmail.com>
 <CALx6S35EwSXNvOxf_a+=5n2xBN6ZTq--cxdciNgCzPnqzxACJA@mail.gmail.com>
 <566687DC.7040805@gmail.com>
 <5666E7EB.40709@mojatatu.com>
 <5666F2DB.5000101@mojatatu.com>
 <20151209014038.GA19097@pox.localdomain>
 <20151209054543.GA7902@ast-mbp.thefacebook.com>
 <20151209125857.GA9900@pox.localdomain>
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
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35466 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752700AbbLIRis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 12:38:48 -0500
Received: by pacej9 with SMTP id ej9so33046415pac.2
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 09:38:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20151209125857.GA9900@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 09, 2015 at 01:58:57PM +0100, Thomas Graf wrote:
> 
> So if the goal is to make the intent available to the hardware in
> a format which both the kernel and the hardware can draw the same
> conclusions from, wouldn't something like P4 + BPF derived from P4
> be a possibly better fit? There is discussion on stateful P4
> processing now.

p4 is a high level language and absolutely not suitable for such purpose.
bpf as intermediate representation can be generated from p4 or C or other
language. There is room to innovate in the language definition on top
and in HW design at the bottom. That's the most flexible model.
