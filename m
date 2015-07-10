From: Sowmini Varadhan <sowmini05@gmail.com>
Subject: Re: [RFC net-next 3/6] net: Introduce VRF device driver - v2
Date: Fri, 10 Jul 2015 05:28:54 +0200
Message-ID: <CACP96tQNsx4Za1Oy1Gkdwn5=t2cqWjJVunHQn7FSZZP75twSSA@mail.gmail.com>
References: <1436195001-4818-1-git-send-email-dsa@cumulusnetworks.com>
	<1436195001-4818-4-git-send-email-dsa@cumulusnetworks.com>
	<CACP96tTyw+J7swi-+GJMwKKVjE9Uk1dJ3m_JKg2o1tyZup+p0w@mail.gmail.com>
	<559EAD2A.2090002@cumulusnetworks.com>
	<CACP96tSp91XYo_UasZexb6c6Krru3LEJvDwEWSgKYgPHJmTkHw@mail.gmail.com>
	<559F3079.1040203@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	ddutt@cumulusnetworks.com,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	hadi@mojatatu.com, "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:38580 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbbGJD2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 23:28:55 -0400
Received: by wicmv11 with SMTP id mv11so3820306wic.1
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 20:28:54 -0700 (PDT)
In-Reply-To: <559F3079.1040203@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 10, 2015 at 4:39 AM, David Ahern <dsa@cumulusnetworks.com> wrote:

> If I set the VRF context (ie., set the SO_BINDTODEVICE for all sockets) of
> any RDS, NFS or any other socket app it runs in that VRF context and works
> just fine

What if the application wants to do SO_BINDTODEVICE?
