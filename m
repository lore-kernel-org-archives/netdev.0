From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] ip route get: change exit to return to support
 batch commands
Date: Thu, 15 Oct 2015 20:38:12 -0600
Message-ID: <56206314.6020601@cumulusnetworks.com>
References: <1444947830-19858-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36678 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751855AbbJPCiR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 22:38:17 -0400
Received: by pacfv9 with SMTP id fv9so6977208pac.3
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 19:38:16 -0700 (PDT)
In-Reply-To: <1444947830-19858-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Roopa:

On 10/15/15 4:23 PM, Roopa Prabhu wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> replace exit with return -2 on rtnl_talk failure
>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
> ---
>   ip/iproute.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/ip/iproute.c b/ip/iproute.c
> index da25548..b137f55 100644
> --- a/ip/iproute.c
> +++ b/ip/iproute.c
> @@ -1643,7 +1643,7 @@ static int iproute_get(int argc, char **argv)
>   		req.r.rtm_family = AF_INET;
>
>   	if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0)
> -		exit(2);
> +		return -2;
>
>   	if (connected && !from_ok) {
>   		struct rtmsg *r = NLMSG_DATA(&req.n);
>

Why return -2 vs exit(2)? What does the change mean to a user or the 
functionality of ip?
