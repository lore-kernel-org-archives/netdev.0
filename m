From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: vxlan: do not use vxlan_net before checking
 event type
Date: Fri, 17 Jan 2014 19:32:38 +0100
Message-ID: <52D97746.1040408@redhat.com>
References: <1389959706-30976-1-git-send-email-dborkman@redhat.com> <CAM_iQpV4FGdbHo9UVFhN9yqhZuGEZdrynikvrTZ0YZJTPVCmLg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16107 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752066AbaAQScp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 13:32:45 -0500
In-Reply-To: <CAM_iQpV4FGdbHo9UVFhN9yqhZuGEZdrynikvrTZ0YZJTPVCmLg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/17/2014 06:30 PM, Cong Wang wrote:
> On Fri, Jan 17, 2014 at 3:55 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>> -       if (event == NETDEV_UNREGISTER)
>> +       if (event == NETDEV_UNREGISTER) {
>> +               vn = net_generic(dev_net(dev), vxlan_net_id);
>>                  vxlan_handle_lowerdev_unregister(vn, dev);
>> +       }
>
> There is no need to keep vxlan_handle_lowerdev_unregister(),
> it is too short. So, just use my patch.

If you want to do cleanups, whatever, I really don't care.
You had your chance to complain about that when you reviewed
the initial version ... it has nothing to do with the fix.
