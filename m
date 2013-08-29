From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH iproute2] ipnetns: fix ip batch mode when using 'netns
 exec'
Date: Thu, 29 Aug 2013 14:26:09 +0200
Message-ID: <521F3DE1.5050600@6wind.com>
References: <1377588334-13538-1-git-send-email-nicolas.dichtel@6wind.com> <kvkbf9$j48$2@ger.gmane.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:35652 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751715Ab3H2M0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 08:26:12 -0400
Received: by mail-wi0-f173.google.com with SMTP id ey11so4782717wid.12
        for <netdev@vger.kernel.org>; Thu, 29 Aug 2013 05:26:11 -0700 (PDT)
In-Reply-To: <kvkbf9$j48$2@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 28/08/2013 10:13, Cong Wang a =E9crit :
> On Tue, 27 Aug 2013 at 07:25 GMT, Nicolas Dichtel <nicolas.dichtel@6w=
ind.com> wrote:
>>
>> -			/* If child failed, propagate status */
>> -			if (WIFEXITED(status))
>> -				exit(WEXITSTATUS(status));
>> +			if (WIFEXITED(status)) {
>> +				/* ip must returns the status of the child,
>
> s/returns/return/

Thank you, but please keep all email addresses in cc next time, at leas=
t the author!
