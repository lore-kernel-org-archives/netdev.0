From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2.2 02/22] fjes: Hardware initialization routine
Date: Thu, 20 Aug 2015 15:49:37 -0700 (PDT)
Message-ID: <20150820.154937.1786835766548007732.davem@davemloft.net>
References: <1440060306-13040-1-git-send-email-izumi.taku@jp.fujitsu.com>
	<1440060386-13189-1-git-send-email-izumi.taku@jp.fujitsu.com>
	<1440060386-13189-2-git-send-email-izumi.taku@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, platform-driver-x86@vger.kernel.org,
	dvhart@infradead.org, rkhan@redhat.com,
	alexander.h.duyck@redhat.com, linux-acpi@vger.kernel.org,
	joe@perches.com, sergei.shtylyov@cogentembedded.com,
	stephen@networkplumber.org, yasu.isimatu@gmail.com
To: izumi.taku@jp.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57683 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752964AbbHTWtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 18:49:39 -0400
In-Reply-To: <1440060386-13189-2-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Date: Thu, 20 Aug 2015 17:46:06 +0900

> diff --git a/drivers/net/fjes/fjes.h b/drivers/net/fjes/fjes.h
> index 4622da1..15ded96 100644
> --- a/drivers/net/fjes/fjes.h
> +++ b/drivers/net/fjes/fjes.h
> @@ -28,6 +28,6 @@
>  
>  extern char fjes_driver_name[];
>  extern char fjes_driver_version[];
> -extern u32 fjes_support_mtu[];
> +extern const u32 fjes_support_mtu[];
>  
>  #endif /* FJES_H_ */

This is kind of rediculous.  Just declare it 'const' from the start in the
patch where you add it for the first time.
