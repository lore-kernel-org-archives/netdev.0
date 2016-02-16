From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 00/13] rocker: do world split
Date: Tue, 16 Feb 2016 15:13:35 +0100
Message-ID: <20160216141335.GD2227@nanopsycho.orion>
References: <1455627338-9872-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, David.Laight@ACULAB.COM,
	john.fastabend@gmail.com, alexei.starovoitov@gmail.com,
	daniel@iogearbox.net, prem@barefootnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:34846 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932836AbcBPONi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 09:13:38 -0500
Received: by mail-wm0-f54.google.com with SMTP id c200so163530140wme.0
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 06:13:37 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1455627338-9872-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Feb 16, 2016 at 01:55:25PM CET, jiri@resnulli.us wrote:
>From: Jiri Pirko <jiri@mellanox.com>
>
>This patchset allows new rocker worlds to be easily added in future.
>Two new worlds are now under development: P4 and eBPF.
>
>The main part of the patchset is the OF-DPA carve-out. It resuts in OF-DPA
>specific file. Clean cut.
>
>Note this patchset is based on my original attempt in October 2015.
>I had to rebase, included all suggestions and did lot of small changes.
>Main change to go with all-port-one-world approach. Port world is set according
>to what is setup in HW. Not possible to change worlds from driver.

I found an issue in 12/13. Will send v2 soon.
