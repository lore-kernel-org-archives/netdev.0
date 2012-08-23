From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [RFC PATCH bridge 4/5] bridge: Add private ioctls to configure
 vlans on bridge ports
Date: Thu, 23 Aug 2012 15:41:00 -0400
Message-ID: <5036874C.6020804@redhat.com>
References: <1345750195-31598-1-git-send-email-vyasevic@redhat.com> <1345750195-31598-5-git-send-email-vyasevic@redhat.com> <20120823123809.1a4adfbe@nehalam.linuxnetplumber.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16353 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030725Ab2HWTlC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 15:41:02 -0400
In-Reply-To: <20120823123809.1a4adfbe@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/23/2012 03:38 PM, Stephen Hemminger wrote:
> On Thu, 23 Aug 2012 15:29:54 -0400
> Vlad Yasevich <vyasevic@redhat.com> wrote:
>
>> Add a private ioctl to add and remove vlan configuration on bridge port.
>>
>> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
>> ---
>>   include/linux/if_bridge.h |    2 +
>>   net/bridge/br_if.c        |   69 +++++++++++++++++++++++++++++++++++++++++++++
>>   net/bridge/br_ioctl.c     |   31 ++++++++++++++++++++
>>   net/bridge/br_private.h   |    2 +
>>   4 files changed, 104 insertions(+), 0 deletions(-)
>
>
> Don't go down this dead end.
>
> The ioctl interface to bridge is deprecated because private ioctl's
> can not be handled when running 32 bit user space on 64 bit kernel.
>


Went down this road because is was easier to do.  The plan is to do this 
over netlink

-vlad
