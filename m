From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/6] cxgb4: Add register, message, and FW definitions
Date: Tue, 30 Mar 2010 14:09:28 -0700
Message-ID: <20100330140928.3a9c3f34@nehalam>
References: <1269975142-30896-1-git-send-email-dm@chelsio.com>
	<1269975142-30896-2-git-send-email-dm@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44095 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755518Ab0C3VJe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Mar 2010 17:09:34 -0400
In-Reply-To: <1269975142-30896-2-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Mar 2010 10:52:17 -0800
Dimitris Michailidis <dm@chelsio.com> wrote:

> +union opcode_tid {
> +	__be32 opcode_tid;
> +	__u8 opcode;
> +};
> +

The intent of the __types like __u8 etc are that these types
should only be used by structures that are part in some way of
a kernel to userspace API. Any structures which are only used
in the kernel should just use the regular type (ie u8).

I say intent because many places do not follow this practice.

-- 
