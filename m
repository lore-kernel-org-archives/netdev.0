From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC][patch 1/4] Network namespaces: cleanup of dev_base list use
Date: Tue, 27 Jun 2006 05:13:28 -0600
Message-ID: <m11wtaonqf.fsf@ebiederm.dsl.xmission.com>
References: <20060626134945.A28942@castle.nmd.msu.ru>
	<m1odwguez3.fsf@ebiederm.dsl.xmission.com> <44A0D755.5090204@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrey Savochkin <saw@swsoft.com>, dlezcano@fr.ibm.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	serue@us.ibm.com, haveblue@us.ibm.com, clg@fr.ibm.com,
	Andrew Morton <akpm@osdl.org>, herbert@13thfloor.at,
	devel@openvz.org, sam@vilain.net, viro@ftp.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:15235 "EHLO
	ebiederm.dsl.xmission.com") by vger.kernel.org with ESMTP
	id S933398AbWF0LOu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 07:14:50 -0400
To: Kirill Korotaev <dev@sw.ru>
In-Reply-To: <44A0D755.5090204@sw.ru> (Kirill Korotaev's message of "Tue, 27
	Jun 2006 10:59:33 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kirill Korotaev <dev@sw.ru> writes:

>>>Cleanup of dev_base list use, with the aim to make device list per-namespace.
>>>In almost every occasion, use of dev_base variable and dev->next pointer
>>>could be easily replaced by for_each_netdev loop.
>>>A few most complicated places were converted to using
>>>first_netdev()/next_netdev().
>> As a proof of concept patch this is ok.
>> As a real world patch this is much too big, which prevents review.
>> Plus it takes a few actions that are more than replace just
>> iterators through the device list.
> Mmm, actually it is a whole changeset and should go as a one patch. I didn't
> find it to be big and my review took only 5-10mins..
> I also don't think that mailing each driver maintainer is a good idea.
> Only if we want to make some buzz :)

Thanks for supporting my case.  You reviewed it and missed the obvious typo.
I do agree that a patchset doing it all should happen at once.

As for not mailing the maintainers of the code we are changing.  That
would just be irresponsible.

Eric
