From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHv2] net: usbnet: support 64bit stats in qmi_wwan driver
Date: Fri, 24 Mar 2017 11:48:53 -0700
Message-ID: <20170324114853.6ec9b09e@xeon-e3>
References: <1490318850-23252-1-git-send-email-gerg@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bjorn@mork.no, oneukum@suse.com, netdev@vger.kernel.org,
        linux-usb@vger.kernel.org
To: Greg Ungerer <gerg@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36437 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965758AbdCXStM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 14:49:12 -0400
Received: by mail-pf0-f174.google.com with SMTP id o126so4498859pfb.3
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 11:49:12 -0700 (PDT)
In-Reply-To: <1490318850-23252-1-git-send-email-gerg@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 24 Mar 2017 11:27:30 +1000
Greg Ungerer <gerg@linux-m68k.org> wrote:

> +struct usbnet_stats64 {
> +	struct u64_stats_sync	syncp;
> +	u64			rx_packets;
> +	u64			rx_bytes;
> +	u64			tx_packets;
> +	u64			tx_bytes;
> +};
> +

There already is similar structure in netdevice.h

/* often modified stats are per-CPU, other are shared (netdev->stats) */
struct pcpu_sw_netstats {
	u64     rx_packets;
	u64     rx_bytes;
	u64     tx_packets;
	u64     tx_bytes;
	struct u64_stats_sync   syncp;
};
