From: Andrew Grover <andy.grover@gmail.com>
Subject: Re: [PATCH 04/21] RDS: Transport code
Date: Tue, 27 Jan 2009 11:36:37 -0800
Message-ID: <c0a09e5c0901271136h4ac81f28g143d1b084cc1076@mail.gmail.com>
References: <1233022678-9259-1-git-send-email-andy.grover@oracle.com>
	 <1233022678-9259-5-git-send-email-andy.grover@oracle.com>
	 <20090127131808.GF2646@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Andy Grover <andy.grover@oracle.com>, rdreier@cisco.com,
	rds-devel@oss.oracle.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.246]:64590 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756341AbZA0Tgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 14:36:40 -0500
Received: by an-out-0708.google.com with SMTP id c2so1508717anc.1
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2009 11:36:38 -0800 (PST)
In-Reply-To: <20090127131808.GF2646@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 27, 2009 at 5:18 AM, Evgeniy Polyakov <zbr@ioremap.net> wrote:
> On Mon, Jan 26, 2009 at 06:17:41PM -0800, Andy Grover (andy.grover@oracle.com) wrote:
>> +static LIST_HEAD(transports);
>> +static DECLARE_RWSEM(trans_sem);
>> +
>
> RDS_ prefix?

Even needed for statics?

>> +int rds_trans_register(struct rds_transport *trans)
>> +{
>> +     BUG_ON(strlen(trans->t_name) + 1 >
>> +            sizeof(((struct rds_info_connection *)0)->transport));
>> +
>
> Wow. Why not declare 15 as some constant and put it into rds_transport
> structure definition?

Makes sense.

>> +        if (IN_LOOPBACK(ntohl(addr)))
>> +                return &rds_loop_transport;
>> +
>
> Tabs have run away.

Will fix. Thanks.

Regards -- Andy
