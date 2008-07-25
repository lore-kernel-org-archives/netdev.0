From: "Julius Volz" <juliusv@google.com>
Subject: Re: [PATCHv2 2/2] IPVS: Add genetlink interface implementation
Date: Sat, 26 Jul 2008 00:39:10 +0200
Message-ID: <f4845fc0807251539w6fe4347dref663f07794cf45c@mail.gmail.com>
References: <1216645375-20410-1-git-send-email-juliusv@google.com>
	 <1216645375-20410-3-git-send-email-juliusv@google.com>
	 <20080724235833.GD20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lvs-devel@vger.kernel.org,
	horms@verge.net.au, kaber@trash.net, davem@davemloft.net,
	vbusam@google.com
To: "Thomas Graf" <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:50758 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751714AbYGYWjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 18:39:19 -0400
Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id m6PMdBMh012989
	for <netdev@vger.kernel.org>; Fri, 25 Jul 2008 23:39:12 +0100
Received: from wf-out-1314.google.com (wfd26.prod.google.com [10.142.4.26])
	by zps36.corp.google.com with ESMTP id m6PMbkcc022465
	for <netdev@vger.kernel.org>; Fri, 25 Jul 2008 15:39:11 -0700
Received: by wf-out-1314.google.com with SMTP id 26so4015654wfd.13
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2008 15:39:10 -0700 (PDT)
In-Reply-To: <20080724235833.GD20815@postel.suug.ch>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 25, 2008 at 1:58 AM, Thomas Graf <tgraf@suug.ch> wrote:
> * Julius Volz <juliusv@google.com> 2008-07-21 15:02
>> +static int ip_vs_genl_parse_dest(struct ip_vs_dest_user *udest,
>> +                              struct nlattr *nla, int full_entry)
>> +{
>> +     struct nlattr *attrs[IPVS_SVC_ATTR_MAX + 1];
>> +     struct nlattr *nla_addr, *nla_port;
>> +
>> +     /* Parse mandatory identifying destination fields first */
>> +     if (nla == NULL ||
>> +         nla_parse_nested(attrs, IPVS_DEST_ATTR_MAX, nla, ip_vs_dest_policy))
>
> Small typo here, attrs[] is defined with a length of IPVS_SVC_ATTR_MAX+1
> while IPVS_DEST_ATTR_MAX is passed to to nla_parse_nested.

Right, thanks for catching this! Will include this in the next
iteration after vacation...

Julius

-- 
Google Switzerland GmbH
