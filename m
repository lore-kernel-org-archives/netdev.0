From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next RFC v2 2/3] ipv4: add support for light weight
 tunnel encap attributes
Date: Fri, 19 Jun 2015 08:15:02 -0700
Message-ID: <558431F6.8030308@cumulusnetworks.com>
References: <1434689355-4088-3-git-send-email-roopa@cumulusnetworks.com> <alpine.LFD.2.11.1506190857520.1731@ja.home.ssi.bg> <558424E8.5090806@cumulusnetworks.com> <55842D5B.90608@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Julian Anastasov <ja@ssi.bg>, ebiederm@xmission.com, tgraf@suug.ch,
	davem@davemloft.net, netdev@vger.kernel.org
To: Robert Shearman <rshearma@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33478 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752174AbbFSPPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2015 11:15:05 -0400
Received: by padev16 with SMTP id ev16so87286055pad.0
        for <netdev@vger.kernel.org>; Fri, 19 Jun 2015 08:15:04 -0700 (PDT)
In-Reply-To: <55842D5B.90608@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/19/15, 7:55 AM, Robert Shearman wrote:
> On 19/06/15 15:19, roopa wrote:
>> On 6/18/15, 11:59 PM, Julian Anastasov wrote:
>>>       Some other places may need changes:
>>>
>>> - nh_comp: there is logic that decides if same fib_info
>>> is reused from many fib nodes. There should be check
>>> if NH matches by nh_lwtstate.
>>
>> yes, i will add that.
>
> One other place - fib_nh_match. This is used when deleting a route to 
> verify that any supplied rtnetlink properties match the route in the fib.
ack, thanks!.
