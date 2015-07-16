From: Veaceslav Falico <vfalico@gmail.com>
Subject: Re: [PATCH net] bonding: fix destruction of bond with devices
 different from arphrd_ether
Date: Thu, 16 Jul 2015 08:14:31 +0200
Message-ID: <20150716061431.GA19448@vps.falico.eu>
References: <55A69D17.5030800@cumulusnetworks.com>
 <1436989971-32761-1-git-send-email-razor@blackwall.org>
 <87io9lcag3.fsf@x220.int.ebiederm.org>
 <55A6E48E.3020206@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Nikolay Aleksandrov <razor@blackwall.org>,
	netdev@vger.kernel.org, j.vosburgh@gmail.com,
	gospo@cumulusnetworks.com, clsoto@linux.vnet.ibm.com,
	davem@davemloft.net
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f176.google.com ([209.85.213.176]:33161 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403AbbGPGOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 02:14:35 -0400
Received: by iggp10 with SMTP id p10so6401201igg.0
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 23:14:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <55A6E48E.3020206@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 16, 2015 at 12:54:06AM +0200, Nikolay Aleksandrov wrote:
...snip...
>My personal opinion would be to disable non-ethernet devices, but support was
>already added and has been there for a long time so we have to fix this for
>the older releases, I don't mind removing non-ethernet device support for net-next
>but I'm guessing there're people still using that like the case that started
>this thread.

Yep, last time non-ethernet devices broke there were quite a few reports
for ppp users, and infiniband is indeed used a lot too. No options here, we
must support it...
