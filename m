From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [RFC] bridge and friends: reduce TheLinuxWay(tm)
Date: Wed, 16 Oct 2013 10:05:25 -0400
Message-ID: <525E9D25.30504@mojatatu.com>
References: <525C62D5.3090004@mojatatu.com> <20131014144156.6dc52a78@nehalam.linuxnetplumber.net> <525E9AB1.6090502@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f178.google.com ([209.85.213.178]:65217 "EHLO
	mail-ye0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934103Ab3JPONQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 10:13:16 -0400
Received: by mail-ye0-f178.google.com with SMTP id l13so159819yen.23
        for <netdev@vger.kernel.org>; Wed, 16 Oct 2013 07:13:16 -0700 (PDT)
In-Reply-To: <525E9AB1.6090502@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/13 09:54, Jamal Hadi Salim wrote:

> - get attributes for bridge interface XXX; there using IFLA_EXT_MASK
> I think it should be using ifm->ifindex


No this doesnt work. Filtering needs to be done in user space ;-<
IMO: The behavior here should be no different then when getting a link.
Will you accept a patch for this?

cheers,
jamal
