From: Phil Sutter <phil@nwl.cc>
Subject: Re: [iproute2 1/1] man: tc-ife.8: man page for ife action
Date: Sat, 30 Apr 2016 13:35:07 +0200
Message-ID: <20160430113507.GM28435@orbyte.nwl.cc>
References: <1462013884-4971-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	lucasb@mojatatu.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:36106 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751403AbcD3LfK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Apr 2016 07:35:10 -0400
Content-Disposition: inline
In-Reply-To: <1462013884-4971-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 30, 2016 at 06:58:04AM -0400, Jamal Hadi Salim wrote:
> From: Lucas Bates <lucasb@mojatatu.com>
> 
> Signed-off-by: Lucas Bates <lucasb@mojatatu.com>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>

Acked-by: Phil Sutter <phil@nwl.cc>

Nit-picking on two things below, but merely as a hint - I don't think
they need to be fixed before applying this.

[...]
> +.SH NAME
> +IFE - encapsulate/decapsulate metadata
> +.SH SYNOPSIS
> +.in +8
> +.ti -8
> +.BR tc " ... " "action"
> +.B "ife"

The quotes around 'action' and 'ife' are not necessary. Furthermore,
the two lines can be combined:

> +.I DIRECTION ACTION
> +.RB "[ " dst
> +.IR DMAC " ] "
> +.RB "[ " src
> +.IR SMAC " ] "
> +.RB "[ " type
> +.IR TYPE " ] "
> +.R "[ " 

This adds a trailing whitespace. Checkpatch.pl finds these things. ;)

Thanks, Phil
