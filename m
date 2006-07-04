From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [patch 1/7] net_device list cleanup: core
Date: Tue, 4 Jul 2006 20:35:37 +0400
Message-ID: <20060704163537.GA10990@ms2.inr.ac.ru>
References: <20060630150823.A22285@castle.nmd.msu.ru> <20060703174650.GA22295@infradead.org> <20060704112405.A25305@castle.nmd.msu.ru> <20060704091003.GA17961@infradead.org> <20060704185035.A29778@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, netdev@vger.kernel.org,
	Kirill Korotaev <dev@openvz.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:49837 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S932252AbWGDQf5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jul 2006 12:35:57 -0400
To: Andrey Savochkin <saw@swsoft.com>
Content-Disposition: inline
In-Reply-To: <20060704185035.A29778@castle.nmd.msu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Different modules want different kinds of lookup.
> So, I'm thinking about something like ilookup5.
....
> The next question: would people agree to review a patch doing this for
> net_devices? :)

One not original suggestion, which did not sound nevertheless:
to implement netdev_iterate_list() or whatever, update only core
and a few of devices and deprecate dev_base_head
with __deprecated_for_modules adding it to
Documentation/feature-removal-schedule.txt

Alexey
