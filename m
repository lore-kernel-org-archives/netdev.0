From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH net-next] tcp: add CDG congestion control
Date: Mon, 18 May 2015 15:16:48 -0700
Message-ID: <20150518151648.6d33128c@urahara>
References: <1431894670-12609-1-git-send-email-kennetkl@ifi.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Hayes <davihay@ifi.uio.no>,
	Yuchung Cheng <ycheng@google.com>,
	Andreas Petlund <apetlund@simula.no>
To: Kenneth Klette Jonassen <kennetkl@ifi.uio.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:34398 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750858AbbERWQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 18:16:45 -0400
Received: by pdbnk13 with SMTP id nk13so71028582pdb.1
        for <netdev@vger.kernel.org>; Mon, 18 May 2015 15:16:45 -0700 (PDT)
In-Reply-To: <1431894670-12609-1-git-send-email-kennetkl@ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am really happy to see more congestion control development.

> +static  int window __read_mostly = 8;
> +static bool use_shadow __read_mostly = true;
> +static bool use_tolerance __read_mostly;
> +static uint backoff_beta __read_mostly = 0.70 * 1024;
> +static uint backoff_factor __read_mostly = 333;
> +static uint ineffective_thresh __read_mostly = 5;
> +static uint ineffective_hold __read_mostly = 5;

Module parameters make for rather ugly tuning.
They are ok for testing but difficult to use in real life.
