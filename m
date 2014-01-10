From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: vxlan: when lower dev unregisters remove
 vxlan dev as well
Date: Fri, 10 Jan 2014 20:16:07 +0100
Message-ID: <52D046F7.3010103@redhat.com>
References: <1389358907-19885-1-git-send-email-dborkman@redhat.com> <CAHA+R7NPyEmSpmojrM6pOsAVq3B6NjVWWCw0oQMPZFdCaDW9sA@mail.gmail.com> <52D044E0.1090206@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30683 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751209AbaAJTQO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 14:16:14 -0500
In-Reply-To: <52D044E0.1090206@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/10/2014 08:07 PM, Daniel Borkmann wrote:
> On 01/10/2014 07:51 PM, Cong Wang wrote:
>> On Fri, Jan 10, 2014 at 5:01 AM, Daniel Borkmann <dborkman@redhat.com> wrote:

>> I think you need to flush fdb as well?
>
> Seems this is not done through normal rtnl_ops->dellink(); vxlan_dellink()
> is what we call there as well ...

Ok, this is being flushed during ndo_stop().
