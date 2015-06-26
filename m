From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ss: add support for segs_in and segs_out
Date: Thu, 25 Jun 2015 23:52:04 -0400
Message-ID: <20150625235204.53d39594@uryu.home.lan>
References: <1432666481-1582-1-git-send-email-kraig@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, mleitner@redhat.com, netdev@vger.kernel.org
To: Craig Gallek <kraig@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:37265 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751617AbbFZDw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 23:52:29 -0400
Received: by igblr2 with SMTP id lr2so5720164igb.0
        for <netdev@vger.kernel.org>; Thu, 25 Jun 2015 20:52:29 -0700 (PDT)
In-Reply-To: <1432666481-1582-1-git-send-email-kraig@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 May 2015 14:54:41 -0400
Craig Gallek <kraig@google.com> wrote:

> Two new tcp_info fields: tcpi_segs_in and tcpi_segs_out.
> (2efd055c53c06b7e89c167c98069bab9afce7e59)
> 
> ~: ss -ti src :22
> 	 cubic wscale:7,6 rto:201 rtt:0.244/0.012 ato:40 mss:1418 cwnd:21 bytes_acked:80605 bytes_received:20491 segs_out:414 segs_in:600 send 976.3Mbps lastsnd:23 lastrcv:23 lastack:22 pacing_rate 1952.7Mbps rcv_rtt:98 rcv_space:28960
> 
> Signed-off-by: Craig Gallek <kraig@google.com>

Applied to net-next branch
