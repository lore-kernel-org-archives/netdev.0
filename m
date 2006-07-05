From: Andrey Savochkin <saw@swsoft.com>
Subject: Re: [patch 1/7] net_device list cleanup: core
Date: Wed, 5 Jul 2006 12:26:42 +0400
Message-ID: <20060705122642.A5159@castle.nmd.msu.ru>
References: <20060630150823.A22285@castle.nmd.msu.ru> <20060703174650.GA22295@infradead.org> <20060704112405.A25305@castle.nmd.msu.ru> <20060704091003.GA17961@infradead.org> <20060704185035.A29778@castle.nmd.msu.ru> <20060704163537.GA10990@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	Kirill Korotaev <dev@openvz.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from castle.nmd.msu.ru ([193.232.112.53]:4367 "HELO
	castle.nmd.msu.ru") by vger.kernel.org with SMTP id S932427AbWGEI0o
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 04:26:44 -0400
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20060704163537.GA10990@ms2.inr.ac.ru>; from "A.N.Kuznetsov" on Tue, Jul 04, 2006 at 08:35:37PM
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 04, 2006 at 08:35:37PM +0400, A.N.Kuznetsov wrote:
> 
> > Different modules want different kinds of lookup.
> > So, I'm thinking about something like ilookup5.
> ....
> > The next question: would people agree to review a patch doing this for
> > net_devices? :)
> 
> One not original suggestion, which did not sound nevertheless:
> to implement netdev_iterate_list() or whatever, update only core
> and a few of devices and deprecate dev_base_head
> with __deprecated_for_modules adding it to
> Documentation/feature-removal-schedule.txt

I like this idea

	Andrey
