From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 iproute2 3/3] ss: Add support to filter on device
Date: Mon, 27 Jun 2016 14:13:04 -0700
Message-ID: <20160627141304.2178a549@xeon-e3>
References: <1467052465-14488-1-git-send-email-dsa@cumulusnetworks.com>
	<1467052465-14488-4-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:32885 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749AbcF0VMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 17:12:51 -0400
Received: by mail-pf0-f180.google.com with SMTP id i123so65369879pfg.0
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 14:12:51 -0700 (PDT)
In-Reply-To: <1467052465-14488-4-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Jun 2016 11:34:25 -0700
David Ahern <dsa@cumulusnetworks.com> wrote:

> +		case SSF_DEVCOND:
> +	{
> +		struct aafilter *a = (void *)f->pred;

I don't like the wandering bracket left, but all the code has that.
After this will change it to:
		case SSF_DEVCOND:  {
			struct aafilter *a = f->pred;
...
