From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v3 2/2] rocker: remove swdev mode
Date: Mon, 8 Dec 2014 16:18:35 +0000
Message-ID: <20141208161835.GB9831@casper.infradead.org>
References: <1417935267-6000-3-git-send-email-roopa@cumulusnetworks.com>
 <20141207081928.GA2215@casper.infradead.org>
 <20141208110301.GA1885@nanopsycho.brq.redhat.com>
 <54858E6E.7010707@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, roopa@cumulusnetworks.com,
	sfeldma@gmail.com, jhs@mojatatu.com, bcrl@kvack.org,
	john.fastabend@gmail.com, stephen@networkplumber.org,
	linville@tuxdriver.com, vyasevic@redhat.com,
	netdev@vger.kernel.org, davem@davemloft.net,
	shm@cumulusnetworks.com, gospo@cumulusnetworks.com
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51595 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148AbaLHQSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 11:18:40 -0500
Content-Disposition: inline
In-Reply-To: <54858E6E.7010707@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/08/14 at 12:41pm, Daniel Borkmann wrote:
> On 12/08/2014 12:03 PM, Jiri Pirko wrote:
> >well, I see no problem in using u16. IFLA_BRIDGE_MODE attr is u16 so
> >mode should stay u16.
> >
> >But maybe better to add:
> >#define BRIDGE_MODE_UNDEF 0xFFFF
> 
> Yep, something along these lines seems better.

Using u16 is fine but then all occurences should use it as opposed
to mixed s16/u16 usage as in v3.
