From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH 5/5] net: Use netlink_ns_capable to verify the permisions
 of netlink messages
Date: Wed, 7 May 2014 16:01:33 -0700
Message-ID: <CALCETrVo7ducU3S25Z_4NDB1p72pSLU0oLQh-ppxEWMgqYyjqQ@mail.gmail.com>
References: <87d2g7d9ag.fsf_-_@x220.int.ebiederm.org> <536AB151.2070804@dti2.net>
 <CALCETrXL6eui802diSCrzNEtVcA5f3W58kFj6h4DYobm3YR_JQ@mail.gmail.com> <20140507.185256.496391962242529591.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Vivek Goyal <vgoyal@redhat.com>,
	Simo Sorce <ssorce@redhat.com>,
	"security@kernel.org" <security@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f177.google.com ([209.85.128.177]:38302 "EHLO
	mail-ve0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192AbaEGXBy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 19:01:54 -0400
Received: by mail-ve0-f177.google.com with SMTP id db11so2194405veb.22
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 16:01:53 -0700 (PDT)
In-Reply-To: <20140507.185256.496391962242529591.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 7, 2014 at 3:52 PM, David Miller <davem@davemloft.net> wrote:
> From: Andy Lutomirski <luto@amacapital.net>
> Date: Wed, 7 May 2014 15:26:11 -0700
>
>> So what do we do?  Check permissions on connect and then use the
>> cached result for send on a connected socket?  Check permitted caps
>> instead of effective caps?
>
> It should create the socket after changing perms.

I agree that it should, but it doesn't, and if these patches get
backported, things will break.  OTOH, if the patches don't get
backported, things may still break, and we have a possibly rather
severe unfixed vulnerability.

--Andy
