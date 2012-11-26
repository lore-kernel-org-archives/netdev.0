From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH RFC 0/5] Containerize syslog
Date: Mon, 26 Nov 2012 09:16:06 -0600
Message-ID: <87sj7wwg21.fsf@xmission.com>
References: <50A9EAD8.9090501@gmail.com>
	<20121119143702.GB4620@mail.hallyn.com> <50ACA05F.7080005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Serge E. Hallyn" <serge@hallyn.com>, serge.hallyn@canonical.com,
	containers@lists.linux-foundation.org, netdev@vger.kernel.org
To: Rui Xiang <leo.ruixiang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:59697 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753719Ab2KZPQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 10:16:49 -0500
In-Reply-To: <50ACA05F.7080005@gmail.com> (Rui Xiang's message of "Wed, 21 Nov
	2012 17:35:27 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rui Xiang <leo.ruixiang@gmail.com> writes:

> On 2012-11-19 22:37, Serge E. Hallyn wrote:

>> I understand that user namespaces aren't 100% usable yet, but looking
>> long term, is there a reason to have the syslog namespace separate
>> from user namespace?
>
> Actually we don't have strong preference. We'll think more about it. Hope we can make
> consensus with Eric.

I hope I am not hard to work with.  My primary concern is reasonable
looking code and good long term maintainable semantics.

I really don't care in which namespace where we file the kernel log
statements.

I care much more about which kernel log print statements we want filed
differently.

Eric
