From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next RFC] mpls: support for dead routes
Date: Sun, 01 Nov 2015 15:27:00 -0600
Message-ID: <87twp5tnq3.fsf@x220.int.ebiederm.org>
References: <1446133748-13738-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: rshearma@brocade.com, davem@davemloft.net, netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:50551 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752698AbbKAVe5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2015 16:34:57 -0500
In-Reply-To: <1446133748-13738-1-git-send-email-roopa@cumulusnetworks.com>
	(Roopa Prabhu's message of "Thu, 29 Oct 2015 08:49:08 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roopa Prabhu <roopa@cumulusnetworks.com> writes:

> diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
> index c70d750..7db9678 100644
> --- a/net/mpls/af_mpls.c
> +++ b/net/mpls/af_mpls.c
> @@ -27,6 +27,8 @@
>   */
>  #define MAX_MP_SELECT_LABELS 4
>  
> +u32 mpls_multipath_secret __read_mostly;

This mpls_multipath_secret is never used.

Eric
