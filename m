From: Mike Rapoport <mike.rapoport@ravellosystems.com>
Subject: Re: [PATCH net-next v4 0/2] vxlan: allow specifying multiple default destinations
Date: Sun, 23 Jun 2013 19:57:05 +0300
Message-ID: <CAF1J0HMNNz-1BVn0vjtK7+NLCnBo49NFQxsFPh3+hhZ8YAr+YA@mail.gmail.com>
References: <1371999276-23948-1-git-send-email-mike.rapoport@ravellosystems.com>
	<20130623092711.3dac445a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Stevens <dlstevens@us.ibm.com>, Thomas Graf <tgraf@suug.ch>,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog108.obsmtp.com ([74.125.245.84]:58792 "HELO
	na3sys010aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751637Ab3FWQ5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Jun 2013 12:57:07 -0400
Received: by mail-ob0-f173.google.com with SMTP id wc20so9912737obb.4
        for <netdev@vger.kernel.org>; Sun, 23 Jun 2013 09:57:05 -0700 (PDT)
In-Reply-To: <20130623092711.3dac445a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 23, 2013 at 7:27 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Sun, 23 Jun 2013 17:54:34 +0300
> Mike Rapoport <mike.rapoport@ravellosystems.com> wrote:
>
>> Hi,
>>
>> These patches add ability to specify multiple default destinations to
>> vxlan. This ability is usefull in cases when multicast are disabled on
>> infrastructure level, for instance in public clouds.
>>
>> v4 changes:
>> * rebased on Stephen Hemminger vxlan-next tree
>> * updates to netlink interface according to Thomas Graf comments
>>
>> v3 changes:
>> * make netlink interface for remote destinations management more
>>   generic and extend vxlan_validate to handle newly added atttributes.
>>   (as proposed by Thomas Graf)
>>
>> v2 changes:
>> * rebased on current net-next
>> * flush default destinations list at dellink as per Atzm Watanabe comment
>> * support only IPv4
>>
>>
>> Mike Rapoport (2):
>>   vxlan: introduce vxlan_rdst_append
>>   vxlan: allow specifying multiple default destinations
>>
>>  drivers/net/vxlan.c          | 282 +++++++++++++++++++++++++++++++++++++++++--
>>  include/uapi/linux/if_link.h |  17 +++
>>  2 files changed, 286 insertions(+), 13 deletions(-)
>>
>
> Could you base these off of my vxlan-next tree. We have several contributors
> all overlapping right now: IPv6, IBM, OVS.

Already did, noted in the changelog

--
Sincerely yours,
Mike.
