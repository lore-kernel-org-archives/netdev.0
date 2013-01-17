From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [net-next 04/14] e1000e: add support for IEEE-1588 PTP
Date: Thu, 17 Jan 2013 07:56:26 -0800
Message-ID: <20130117075626.40eb1500@nehalam.linuxnetplumber.net>
References: <1358422519-20981-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1358422519-20981-5-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Bruce Allan <bruce.w.allan@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Richard Cochran <richardcochran@gmail.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:59108 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756737Ab3AQP5y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 10:57:54 -0500
Received: by mail-pb0-f49.google.com with SMTP id un15so1472767pbc.8
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 07:57:53 -0800 (PST)
In-Reply-To: <1358422519-20981-5-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Jan 2013 03:35:09 -0800
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> +static struct ptp_clock_info e1000e_ptp_clock_info = {

Should be static const since it is immutable and contains function pointers.
