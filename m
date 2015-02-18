From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Subject: Setting RPS affinities from network driver
Date: Wed, 18 Feb 2015 11:46:50 +0530
Message-ID: <CA+sq2CeC89YfaTM18JR9dFOoNAbohGk=gFXSkM_4q2oySB12GA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:37406 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067AbbBRGQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2015 01:16:51 -0500
Received: by wesw55 with SMTP id w55so2629467wes.4
        for <netdev@vger.kernel.org>; Tue, 17 Feb 2015 22:16:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am writing a network driver for a multicore SOC with a on-board
network interface and would like to set RPS affinities from driver by
default. So that the network performance is good with whatever driver
supplied. Ofcourse these can be further adjusted from userspace
anyways.

Is there a way to set RPS settings from driver itself ?
The only issue i am seeing is while setting 'rps_needed' key.

static_key_slow_inc(&rps_needed);

Currently this is not exported, so having issues while compiling
driver as module.

If i export this symbol, will it be acceptable ?


Thanks,
Sunil.
