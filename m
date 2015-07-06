From: roopa <roopa@cumulusnetworks.com>
Subject: Re: Summary lightweight tunnel discussion at NFWS
Date: Mon, 06 Jul 2015 08:24:27 -0700
Message-ID: <559A9DAB.2040001@cumulusnetworks.com>
References: <1434689355-4088-3-git-send-email-roopa@cumulusnetworks.com> <20150703100023.GH26182@pox.localdomain> <5598CCF9.4090407@cumulusnetworks.com> <20150706130348.GA19361@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, rshearma@brocade.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:34979 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751933AbbGFPYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2015 11:24:30 -0400
Received: by pdbci14 with SMTP id ci14so107734183pdb.2
        for <netdev@vger.kernel.org>; Mon, 06 Jul 2015 08:24:29 -0700 (PDT)
In-Reply-To: <20150706130348.GA19361@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/6/15, 6:03 AM, Thomas Graf wrote:
> The integration into the routing code looks much better now. Any
> chance you can rebase your tree and squash it into logical
> commits?
Will do today.
>   I'm rebasing again onto yours and I think we should submit
> all of this in a single series so everything can be reviewed in a
> single thread.
agreed.
>
> All of this is only useful if distros enable this by default which
> minimize the value of a config option quite a bit. I think what you
> have your latest tree is a good balance.
ok
>
>> I have been thinking of moving lwtstate from rtable to struct dst_entry.
>> I will also look at the dst_metadata.
> I thought about the same. The introduction of dst_metadata makes
> that a bit pointless because we don't want to store a pointer to the
> tunnel metadata but allocate the metadata as a dst directly to avoid
> the indirection. We need the separate code paths anyway until v6 and
> v4 routing are merged so we would save very little while penalizing
> everyone except rtable and fib6.
agreed,

thanks,
Roopa
