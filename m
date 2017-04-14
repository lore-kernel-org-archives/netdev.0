From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next 1/3] ip: add ip sr command to control
 SR-IPv6 internal structures
Date: Fri, 14 Apr 2017 15:45:31 -0700
Message-ID: <20170414154531.7ef9df18@xeon-e3>
References: <20170414123623.28190-1-david.lebrun@uclouvain.be>
        <20170414123623.28190-2-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Lebrun <david.lebrun@uclouvain.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36341 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752855AbdDNWpe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 18:45:34 -0400
Received: by mail-pf0-f174.google.com with SMTP id 194so5897857pfv.3
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 15:45:34 -0700 (PDT)
In-Reply-To: <20170414123623.28190-2-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Apr 2017 14:36:21 +0200
David Lebrun <david.lebrun@uclouvain.be> wrote:

> +static struct {
> +	int cmd;
Why not unsigned? you only assign positive values
> +	struct in6_addr addr;
> +	__u32 keyid;
> +	char *pass;
Why not const char *? or do you free the value on exit?
> +	__u8 alg_id;
> +} opts;
> +
