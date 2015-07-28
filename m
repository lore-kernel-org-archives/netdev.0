From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 14/16] net: Add sk_bind_dev_if to task_struct
Date: Tue, 28 Jul 2015 18:52:57 +0200
Message-ID: <1438102377.20182.65.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1438021869-49186-1-git-send-email-dsa@cumulusnetworks.com>
	 <1438021869-49186-15-git-send-email-dsa@cumulusnetworks.com>
	 <87wpxlxrvg.fsf@x220.int.ebiederm.org>
	 <1438085969.25794.14.camel@stressinduktion.org>
	 <1438099265.20182.63.camel@edumazet-glaptop2.roam.corp.google.com>
	 <55B7A8B5.6020305@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, shm@cumulusnetworks.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com,
	jtoppins@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	ddutt@cumulusnetworks.com, nicolas.dichtel@6wind.com,
	stephen@networkplumber.org, hadi@mojatatu.com, davem@davemloft.net,
	svaidya@brocade.com, mingo@kernel.org, luto@amacapital.net
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:37827 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143AbbG1QxC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2015 12:53:02 -0400
Received: by wibud3 with SMTP id ud3so168227589wib.0
        for <netdev@vger.kernel.org>; Tue, 28 Jul 2015 09:53:00 -0700 (PDT)
In-Reply-To: <55B7A8B5.6020305@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-07-28 at 10:07 -0600, David Ahern wrote:

> Problems with using network namespaces for VRFs has been discussed in 
> the past. e.g.,
>      http://www.spinics.net/lists/netdev/msg298368.html

Great. Are you suggesting to get rid of network namespaces ?

If not, your proposal only increases bloat and maintenance burden.

If namespaces cant be fixed, they are the wrong design and we should
remove them.

If they can be fixed, they must be fixed.
