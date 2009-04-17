From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: [PATCH 0/3] ipconfig tweaks
Date: Fri, 17 Apr 2009 16:31:41 +0200
Message-ID: <m3eivr4aia.fsf@ursa.amorsen.dk>
References: <1239874659-19273-1-git-send-email-dmitry.krivoschekov@gmail.com>
	<20090417.012316.209396377.davem@davemloft.net>
	<49E85348.8080906@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Dmitry Krivoschekov <dmitry.krivoschekov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate1.ipvision.dk ([217.195.186.3]:34882 "EHLO
	gate1.ipvision.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753936AbZDQPJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 11:09:10 -0400
In-Reply-To: <49E85348.8080906@gmail.com> (Dmitry Krivoschekov's message of "Fri\, 17 Apr 2009 14\:00\:40 +0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dmitry Krivoschekov <dmitry.krivoschekov@gmail.com> writes:

> as the patches allow you to change that pre-defined delays, i.e. you
> can adjust the delays for your particular system. As I wrote it could
> save about 1 second of boot-up time.

Perhaps it could change the delay to be extremely short (or
non-existent?) for VLAN devices? Currently, starting 1000 VLAN devices
is very painful even without trying to add IP addresses.

Adding IP addresses is even more painful, at least with the Fedora
initscripts, but that is not a kernel issue.

The other option is to just start the devices in parallel.


/Benny

