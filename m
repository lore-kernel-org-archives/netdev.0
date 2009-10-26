From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH v3 1/7] Only parse time stamp TCP option in time wait
 sock
Date: Mon, 26 Oct 2009 12:56:14 -0400
Message-ID: <4AE5D4AE.2080108@gmail.com>
References: <1256544393-12450-1-git-send-email-gilad@codefidence.com> <1256544393-12450-2-git-send-email-gilad@codefidence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ori@comsleep.com,
	Yony Amit <yony@comsleep.com>
To: Gilad Ben-Yossef <gilad@codefidence.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:23881 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751370AbZJZQ4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 12:56:18 -0400
Received: by ey-out-2122.google.com with SMTP id 9so2427019eyd.19
        for <netdev@vger.kernel.org>; Mon, 26 Oct 2009 09:56:22 -0700 (PDT)
In-Reply-To: <1256544393-12450-2-git-send-email-gilad@codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gilad Ben-Yossef wrote:
> Since we only use tcp_parse_options here to check for the exietence
> of TCP timestamp option in the header, it is better to call with
> the "established" flag on.
> 
Please explain how this patch is required for the other patches?

And more importantly, why it is better to call with established on?

And most importantly, what end cases you considered, and how this
interacts with the proposed rfc1323bis changes, especially on reset?
