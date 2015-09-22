From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2] netpoll: Close race condition between poll_one_napi
 and napi_disable
Date: Tue, 22 Sep 2015 15:09:20 -0700
Message-ID: <20150922150920.2a830e62@urahara>
References: <20150922190154.GC31679@hmsreliant.think-freely.org>
	<1442952096-31430-1-git-send-email-nhorman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Neil Horman <nhorman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34658 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759198AbbIVWJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 18:09:09 -0400
Received: by padhy16 with SMTP id hy16so20832586pad.1
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 15:09:09 -0700 (PDT)
In-Reply-To: <1442952096-31430-1-git-send-email-nhorman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 22 Sep 2015 16:01:36 -0400
Neil Horman <nhorman@redhat.com> wrote:

> +	clear_bit(NAPI_STATE_NPSVC, &n->state);
> +
>  }
why introduce extra line here?

> +	/*
> +	 * If we set this bit but see that it has already been set,
> +	 * that indicates that napi has been disabled and we need
> +	 * to abort this operation
> + 	 */
> +
> +	if(test_and_set_bit(NAPI_STATE_NPSVC, &napi->state))

And why introduce line after comment before code.
My preference is to have comment as close to code as possible.
