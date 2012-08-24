From: Naresh Kumar Inna <naresh@chelsio.com>
Subject: Re: [PATCH 5/8] csiostor: Chelsio FCoE offload driver submission
 (sources part 5).
Date: Sat, 25 Aug 2012 00:37:48 +0530
Message-ID: <5037D104.8090103@chelsio.com>
References: <1345760873-12101-1-git-send-email-naresh@chelsio.com>  <1345760873-12101-6-git-send-email-naresh@chelsio.com>  <1345751301.10190.75.camel@haakon2.linux-iscsi.org>  <5037BC94.1050201@chelsio.com> <1345832854.32359.11.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Nicholas A. Bellinger" <nab@linux-iscsi.org>,
	"JBottomley@parallels.com" <JBottomley@parallels.com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
	Dimitrios Michailidis <dm@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Chethan Seshadri <chethan@chelsio.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:23963 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752223Ab2HXTIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 15:08:09 -0400
In-Reply-To: <1345832854.32359.11.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/24/2012 11:57 PM, Joe Perches wrote:
> On Fri, 2012-08-24 at 23:10 +0530, Naresh Kumar Inna wrote:
>> Is there a TRUE/FALSE define in a standard header file?
> 
> include/linux/stddef.h:
> enum {
> 	false	= 0,
> 	true	= 1
> };
> 
>> I see a lot of
>> kernel code defining their own TRUE/FALSE.
> 
> Those should be changed eventually.
> 

Thanks! I will switch over to these macros.
