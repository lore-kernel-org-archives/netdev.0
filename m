From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Sat, 5 Dec 2015 09:53:43 -0800
Message-ID: <CALx6S36-oe5tZ2QAy5rV3SbHveJ7nyfEHArMh2z24zrAuAWY9g@mail.gmail.com>
References: <CAKgT0UepW=VehhXncrAM=tvqrVDD_KOdVJBpwEU+hYTAdMz_dg@mail.gmail.com>
	<CALx6S36Y4fP9a6U40My+kuhik5THPOjHNYfRrVe8Szte03K7Ew@mail.gmail.com>
	<566279E5.9070500@gmail.com>
	<20151205.014909.1572453190886968569.davem@davemloft.net>
	<CAKgT0Uc1bJRrzpLUdr3vOFkYZbcqP=J8wgOz1feF+u04aNBg1g@mail.gmail.com>
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
Received: from mail-ig0-f170.google.com ([209.85.213.170]:37104 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753053AbbLERxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 12:53:44 -0500
Received: by igcto18 with SMTP id to18so56725217igc.0
        for <netdev@vger.kernel.org>; Sat, 05 Dec 2015 09:53:43 -0800 (PST)
In-Reply-To: <CAKgT0Uc1bJRrzpLUdr3vOFkYZbcqP=J8wgOz1feF+u04aNBg1g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Keep in mind I don't represent one of the hardware vendors here
> anymore.  I am approaching this from the customer point of view.  I
> would like to have the performance I can get out of the parts I have.

Trying enabling UDP checksum, GRO/GSO, and Remote Checksum Offload in
VXLAN. Assuming you have a NIC that at least provides UDP checksum
offload and RSS for UDP (may need to be enabled) you can get good
VXLAN performance across a varietyof legacy "dumb" NICs.
