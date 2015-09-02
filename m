From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v2] net: Add table id from route lookup to
 route response
Date: Wed, 2 Sep 2015 13:53:25 -0700
Message-ID: <20150902135325.46aa7cef@urahara>
References: <20150902190836.GD20527@pox.localdomain>
	<1441224980-6201-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34672 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755190AbbIBUxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 16:53:14 -0400
Received: by padhy1 with SMTP id hy1so22659786pad.1
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2015 13:53:14 -0700 (PDT)
In-Reply-To: <1441224980-6201-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  2 Sep 2015 13:16:20 -0700
David Ahern <dsa@cumulusnetworks.com> wrote:

> diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
> index 702024769c74..5add1468350a 100644
> --- a/include/uapi/linux/rtnetlink.h
> +++ b/include/uapi/linux/rtnetlink.h
> @@ -310,6 +310,7 @@ enum rtattr_type_t {
>  	RTA_PREF,
>  	RTA_ENCAP_TYPE,
>  	RTA_ENCAP,
> +	RTA_TABLE_LOOKUP,  /* table hit for fib lookup */

Why add a comment here. There is nothing special that needs a comment.
