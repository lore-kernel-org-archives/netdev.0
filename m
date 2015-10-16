From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2] ip route get: change exit to return to support
 batch commands
Date: Thu, 15 Oct 2015 20:13:23 -0700
Message-ID: <56206B53.1080709@cumulusnetworks.com>
References: <1444947830-19858-1-git-send-email-roopa@cumulusnetworks.com> <56206314.6020601@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35574 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751855AbbJPDNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 23:13:25 -0400
Received: by pabws5 with SMTP id ws5so8624326pab.2
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 20:13:24 -0700 (PDT)
In-Reply-To: <56206314.6020601@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/15/15, 7:38 PM, David Ahern wrote:
> Hi Roopa:
>
> On 10/15/15 4:23 PM, Roopa Prabhu wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> replace exit with return -2 on rtnl_talk failure
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>> ---
>>   ip/iproute.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/ip/iproute.c b/ip/iproute.c
>> index da25548..b137f55 100644
>> --- a/ip/iproute.c
>> +++ b/ip/iproute.c
>> @@ -1643,7 +1643,7 @@ static int iproute_get(int argc, char **argv)
>>           req.r.rtm_family = AF_INET;
>>
>>       if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0)
>> -        exit(2);
>> +        return -2;
>>
>>       if (connected && !from_ok) {
>>           struct rtmsg *r = NLMSG_DATA(&req.n);
>>
>
> Why return -2 vs exit(2)? What does the change mean to a user or the functionality of ip?
Stephen has documented this someplace. I have seen it before. I now forget where. Right now i am just following
the rest of the code.
