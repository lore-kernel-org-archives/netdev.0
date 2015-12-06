From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Sun, 6 Dec 2015 08:31:59 -0800
Message-ID: <CALx6S37rekP6c9umanJAFhzpBC=pvR6VBA6CvR13-n7rhFYT-Q@mail.gmail.com>
References: <CAKgT0Uc1bJRrzpLUdr3vOFkYZbcqP=J8wgOz1feF+u04aNBg1g@mail.gmail.com>
	<20151205.130313.1952213347830357234.davem@davemloft.net>
	<CAKgT0UfQCnz+oGfETZQs-nCP_QL_5qzngB+zC-e6ZN1-kV8C0Q@mail.gmail.com>
	<20151205.172742.1214683922564543621.davem@davemloft.net>
	<CAKgT0Udj2vNjqTO3HQKRoQajm-_Y6PdgQAu23Z8eQfnLRvsUiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	John Linville <linville@tuxdriver.com>,
	Jesse Gross <jesse@kernel.org>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:34528 "EHLO
	mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753182AbbLFQcA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Dec 2015 11:32:00 -0500
Received: by ioir85 with SMTP id r85so160089770ioi.1
        for <netdev@vger.kernel.org>; Sun, 06 Dec 2015 08:31:59 -0800 (PST)
In-Reply-To: <CAKgT0Udj2vNjqTO3HQKRoQajm-_Y6PdgQAu23Z8eQfnLRvsUiQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The only spot I think you and I disagreed on was the approach.  I
> don't know if the hard push back does anything but punish the users by
> delaying the time needed to find a reasonable solution.  I really
> think if we are going to get the hardware vendors to change their
> behavior we have to create a market demand for it.  Having a bit of
> marketable data showing the folly of this approach versus the 1's
> compliment checksum would probably do more to encourage and/or shame
> them into it than simply pushing for this based on engineering
> opinion.
>
I don't know what "marketable data" means. But I do know that we're
like 70 postings into this thread, into the third patch set regarding
this, yet nobody has bothered to contribute any data on what these
patches do and what the quantifiable benefits are with HW offload of
these protocols. I would test this stuff myself, but I don't have
access to any NICs with necessary support. If someone else can start
testing and providing meaningful data it would be most helpful...
