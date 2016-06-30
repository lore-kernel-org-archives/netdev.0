From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH 1/2] ip-address: Support filtering by slave
 type, too
Date: Wed, 29 Jun 2016 17:11:41 -0700
Message-ID: <20160629171141.62b44c1f@xeon-e3>
References: <1467119237-12544-1-git-send-email-phil@nwl.cc>
	<1467119237-12544-2-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:7913 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751376AbcF3ALu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jun 2016 20:11:50 -0400
In-Reply-To: <1467119237-12544-2-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Jun 2016 15:07:16 +0200
Phil Sutter <phil@nwl.cc> wrote:

> +static int match_link_kind(struct rtattr **tb, char *kind, bool slave)

const char *kind ??

> +{
> +	if (!tb[IFLA_LINKINFO])
> +		return -1;
> +
> +	return strcmp(parse_link_kind(tb[IFLA_LINKINFO], slave), kind);
> +}
> +
