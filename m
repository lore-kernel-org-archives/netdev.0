From: Jesse Gross <jesse@nicira.com>
Subject: Re: [ovs-dev] [PATCH net-next 0/8] openvswitch: Add vxlan tunneling support.
Date: Thu, 20 Jun 2013 10:14:12 -0700
Message-ID: <CAEP_g=9pFfXpPbXN7p5wT67kfegOj09KU2Zwunbh-PX_PsWc+w@mail.gmail.com>
References: <1371713175-8037-1-git-send-email-pshelar@nicira.com> <20130620085842.27a588d2@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pravin B Shelar <pshelar@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog108.obsmtp.com ([74.125.149.199]:55117 "HELO
	na3sys009aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S965198Ab3FTROf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 13:14:35 -0400
Received: by mail-ie0-f175.google.com with SMTP id a13so17253582iee.34
        for <netdev@vger.kernel.org>; Thu, 20 Jun 2013 10:14:33 -0700 (PDT)
In-Reply-To: <20130620085842.27a588d2@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 20, 2013 at 8:58 AM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Thu, 20 Jun 2013 00:26:15 -0700
> Pravin B Shelar <pshelar@nicira.com> wrote:
>
>> First two patches fixes vxlan issues.  Next two patches
>> extends vxlan so that openvswitch can share vxlan udp port
>> with vxlan module. Rest of patches refactors vxlan data
>> plane so that ovs can share that code with vxlan module.
>> Last patch adds vxlan-vport to openvswitch.
>>
>> Pravin B Shelar (8):
>>   vxlan: Fix error handling while creating device.
>>   vxlan: Fix sparse wornings.
>>   vxlan: Allow multiple recieve handlers.
>>   vxlan: Extend vxlan handlers for openvswitch.
>>   vxlan: Factor out vxlan send api.
>>   vxlan: Improve vxlan headroom calculation.
>>   vxlan: Add tx-vlan offload support.
>>   openvswitch: Add vxlan tunneling support.
>>
>>  drivers/net/vxlan.c              |  337 +++++++++++++++++++++++++-------------
>>  include/net/vxlan.h              |   33 ++++
>>  include/uapi/linux/openvswitch.h |   11 ++
>>  net/openvswitch/Kconfig          |    1 +
>>  net/openvswitch/Makefile         |    3 +-
>>  net/openvswitch/vport-vxlan.c    |  220 +++++++++++++++++++++++++
>>  net/openvswitch/vport.c          |    3 +
>>  net/openvswitch/vport.h          |    1 +
>>  8 files changed, 490 insertions(+), 119 deletions(-)
>>  create mode 100644 include/net/vxlan.h
>>  create mode 100644 net/openvswitch/vport-vxlan.c
>
> I will merge the first 7 into my vxlan repository and send a pull request.

Once you've done that, I'll resync my tree with net-next and take the last one.
