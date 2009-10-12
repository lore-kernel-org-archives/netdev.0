From: jamal <hadi@cyberus.ca>
Subject: Re: kernel mode pppoe ppp if + ifb + mirred redirect, ethernet
	packets in ifb?!
Date: Mon, 12 Oct 2009 09:10:47 -0400
Message-ID: <1255353047.5406.12.camel@dogo.mojatatu.com>
References: <200910121143.39924.denys@visp.net.lb>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:1819 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754588AbZJLNVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 09:21:05 -0400
Received: by qw-out-2122.google.com with SMTP id 9so548438qwb.37
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2009 06:19:58 -0700 (PDT)
In-Reply-To: <200910121143.39924.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-10-12 at 11:43 +0300, Denys Fedoryschenko wrote:

> Is it expected that redirecting ppp interface, that supposed to be clean IP 
> traffic is becoming eth encapsulated traffic?

No. Imagine if there were other types of packets non-ip for example,
what do you do then? 
this feature is as close as you can get when you do switch level
mirroring or redirection. If you want to edit header before redirect
etc, use pedit (refer to recent discussion with someone who wanted to
replicate packets for redundant routing purposes); 

cheers,
jamal


