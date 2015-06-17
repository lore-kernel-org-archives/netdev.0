From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net] ipv4: include NLM_F_APPEND flag in append route notifications
Date: Wed, 17 Jun 2015 11:07:25 -0700
Message-ID: <5581B75D.6020105@cumulusnetworks.com>
References: <1434471120-26742-1-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bDnVEq1mqUmmYMFAd9CeEbn9tTzD_UnoDKYVScT5G=QJA@mail.gmail.com> <5581893E.3070609@cumulusnetworks.com> <558193C1.70001@gmail.com> <55819E5A.8020801@cumulusnetworks.com> <5581AF03.8010501@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Scott Feldman <sfeldma@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:34525 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756504AbbFQSH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 14:07:26 -0400
Received: by pdbki1 with SMTP id ki1so45685044pdb.1
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 11:07:26 -0700 (PDT)
In-Reply-To: <5581AF03.8010501@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/17/15, 10:31 AM, Alexander Duyck wrote:
>
> I'd say go with something closer to the original patch, but flip the 
> logic like you have here, and lose the "|=" in favor of an "=" since 
> you are either sending a message with 0 or NLM_F_APPEND.
>
> Anyway that is just my $.02.
agreed,

thanks alex, v2 posted..
