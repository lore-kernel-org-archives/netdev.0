From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] Add support for rt_tables.d
Date: Mon, 23 Nov 2015 15:23:33 -0800
Message-ID: <20151123152333.232085f3@xeon-e3>
References: <1447873400-15337-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34543 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085AbbKWXXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 18:23:23 -0500
Received: by padhx2 with SMTP id hx2so205790228pad.1
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 15:23:23 -0800 (PST)
In-Reply-To: <1447873400-15337-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 18 Nov 2015 11:03:20 -0800
David Ahern <dsa@cumulusnetworks.com> wrote:

> Add support for reading table id/name mappings from rt_tables.d
> directory.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  lib/rt_names.c | 18 ++++++++++++++++++
>  1 file changed, 18 insertions(+)

This is a useful concept, and I am for incorporating it in the future.

The consensus practice for other utility is to a '.conf' suffix which
allows for README.

Probably should also ship a README file in the package.
