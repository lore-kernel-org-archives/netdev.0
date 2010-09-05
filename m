From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH] iputils ping,ping6: use monotonic clock to schedule pings
Date: Sun, 05 Sep 2010 15:13:59 +0200
Message-ID: <4C839797.50607@computer.org>
References: <alpine.DEB.1.10.1009051453090.13886@red.crap.retrofitta.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Thomas Habets <thomas@habets.pp.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay008.isp.belgacom.be ([195.238.6.174]:40541 "EHLO
	mailrelay008.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750728Ab0IENPX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Sep 2010 09:15:23 -0400
In-Reply-To: <alpine.DEB.1.10.1009051453090.13886@red.crap.retrofitta.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/09/10 14:58, Thomas Habets wrote:
> +int
> +getclock(struct timeval *tv)
> +{
> +#ifdef CLOCK_MONOTONIC
> + struct timespec ts;
> + if (!clock_gettime(CLOCK_MONOTONIC, &ts)) {
> + tv->tv_sec = ts.tv_sec;
> + tv->tv_usec = ts.tv_nsec / 1000;
> + return;
> + }
> +#endif

Don't you need a return value there?

Jan
