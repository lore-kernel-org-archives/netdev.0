From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2 add hoplimit parsing and update usage and
 documentation
Date: Tue, 1 Dec 2009 15:53:30 -0800
Message-ID: <20091201155330.4b04f5b2@nehalam>
References: <4ACB39F2.6080002@codefidence.com>
	<1254836434.544524.27946.nullmailer@watson.codefidence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ori Finkelman <ori@comsleep.com>,
	Andreas Henriksson <andreas@fatal.se>
To: Gilad Ben-Yossef <gilad@codefidence.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42756 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754755AbZLAXyG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2009 18:54:06 -0500
In-Reply-To: <1254836434.544524.27946.nullmailer@watson.codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 06 Oct 2009 15:40:34 +0200
Gilad Ben-Yossef <gilad@codefidence.com> wrote:

> diff --git a/ip/iproute.c b/ip/iproute.c
> index bf0f31b..aeea93d 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -13,6 +13,8 @@
>   *
>   * Rani Assaf <rani@magic.metawire.com> 980929:	resolve addresses
>   * Kunihiro Ishiguro <kunihiro@zebra.org> 001102: rtnh_ifindex was not initialized
> + * Gilad Ben-Yossef <gilad@codefidence.com> 091006: Add hoplimit option parsing 
> + * and correct usage
>   */
>  

Applied except I removed the comment changelogs from all of iproute now
to discourage individual source attribution.  The contributor information
exists in the git data.

-- 
