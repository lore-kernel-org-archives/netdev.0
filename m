From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [PATCH net-next v2] be2net: log link status
Date: Wed, 22 Apr 2015 16:17:23 +0200
Message-ID: <5537AD73.5070401@redhat.com>
References: <1429710210-7291-1-git-send-email-ivecera@redhat.com> <1429711674.32612.8.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sathya Perla <sathya.perla@emulex.com>,
	Subbu Seetharaman <subbu.seetharaman@emulex.com>,
	Ajit Khaparde <ajit.khaparde@emulex.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45214 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754174AbbDVORb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Apr 2015 10:17:31 -0400
In-Reply-To: <1429711674.32612.8.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/22/2015 04:07 PM, Joe Perches wrote:
> On Wed, 2015-04-22 at 15:43 +0200, Ivan Vecera wrote:
>> >The driver unlike other drivers does not log link state changes.
> Why add all the speed stuff, why not add a query instead?
>
> I think it'd be simpler to add a line like:
> 	status = be_cmd_link_status_query(adapter, &speed, &status, 0);
> before emitting speed/link_status
The func be_link_status_update() is also called from 
be_async_link_state_process() and I'm not sure if it is possible to call 
be_cmd_link_status_query() from its context.

Ivan
