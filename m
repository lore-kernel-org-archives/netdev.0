From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [ovs-dev] [GIT net-next] Open vSwitch
Date: Mon, 13 Jan 2014 18:04:14 +0000
Message-ID: <52D42A9E.1030805@citrix.com>
References: <1389053776-62865-1-git-send-email-jesse@nicira.com> <52CD657F.7080806@citrix.com> <CAEP_g=_pQpH--V+7GSrjGP2z=0TBD_37yXjzTdeKG+2OF3aRaw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	netdev <netdev@vger.kernel.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:58899 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568AbaAMSEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 13:04:16 -0500
In-Reply-To: <CAEP_g=_pQpH--V+7GSrjGP2z=0TBD_37yXjzTdeKG+2OF3aRaw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/14 15:10, Jesse Gross wrote:
> On Wed, Jan 8, 2014 at 9:49 AM, Zoltan Kiss <zoltan.kiss@citrix.com> wrote:
>> Hi,
>>
>> I've tried the latest net-next on a Xenserver install with 1.9.3 userspace,
>> and it seems this patch series broke it (at least after reverting that
>> locally it works now). I haven't went too far yet checking what's the
>> problem, but it seems the xenbrX device doesn't really receive too much of
>> the traffic coming through the NIC. Is it expected?
>
> What do you mean by doesn't receive too much traffic? What does it get?
>

Sorry for the vague error description, now I had more time to look into 
this. I think the problem boils down to this:

Jan 13 17:55:07 localhost ovs-vswitchd: 
07890|netlink_socket|DBG|nl_sock_recv__ (Success): nl(len:274, 
type=29(ovs_packet), flags=0, seq=0, pid=0,genl(cmd=1,version=1)
Jan 13 17:55:07 localhost ovs-vswitchd: 07891|netlink|DBG|attributes 
followed by garbage
Jan 13 17:55:07 localhost ovs-vswitchd: 07892|dpif|WARN|system@xenbr0: 
recv failed (Invalid argument)

That's just keep repeating. I'm keep looking.

Zoli
