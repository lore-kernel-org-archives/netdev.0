From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v6] mpls: support for dead routes
Date: Tue, 01 Dec 2015 20:39:16 -0800
Message-ID: <565E75F4.80905@cumulusnetworks.com>
References: <1448768313-34809-1-git-send-email-roopa@cumulusnetworks.com> <20151201.154324.1248915135840079518.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, rshearma@brocade.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:32867 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752331AbbLBEjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 23:39:18 -0500
Received: by pabfh17 with SMTP id fh17so28870071pab.0
        for <netdev@vger.kernel.org>; Tue, 01 Dec 2015 20:39:18 -0800 (PST)
In-Reply-To: <20151201.154324.1248915135840079518.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/1/15, 12:43 PM, David Miller wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> Date: Sat, 28 Nov 2015 19:38:33 -0800
>
>> Adds support for RTNH_F_DEAD and RTNH_F_LINKDOWN flags on mpls
>> routes due to link events. Also adds code to ignore dead
>> routes during route selection.
> I agree with Robert's feedback that we probably should use
> ACCESS_ONCE(), optionally with a local variable.
>
> Please make this change and I'll apply this patch, thanks Roopa!
ack, will send v7. thanks for review all!.
