From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH 2/2] team: Use new sync_multiple api to sync devices adressess.
Date: Mon, 15 Apr 2013 15:49:33 -0400
Message-ID: <516C59CD.3050509@redhat.com>
References: <1366052997-12435-1-git-send-email-vyasevic@redhat.com> <1366052997-12435-3-git-send-email-vyasevic@redhat.com> <20130415.154539.1016433031972939376.davem@davemloft.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42486 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934335Ab3DOTtg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Apr 2013 15:49:36 -0400
In-Reply-To: <20130415.154539.1016433031972939376.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/15/2013 03:45 PM, David Miller wrote:
> From: Vlad Yasevich <vyasevic@redhat.com>
> Date: Mon, 15 Apr 2013 15:09:57 -0400
>
>> Team drivers attempts to sync addresses to each of of the port
>                                                    ^^^^^
>
> Maybe you meant only one "of" here.
>
>> devices; however, the current api doesn't do anything for anything
>> after the first device.  Switch to using the new api that will
>> actually sync the addresses to all ports.
>
> "anything for anything" sounds awkward, perhaps "anything for devices
> on the list after the first device" or something like that.
>

yes will fix.

-vlad

> Thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
