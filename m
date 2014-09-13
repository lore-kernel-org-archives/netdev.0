From: Nicolas Cavallari <nicolas.cavallari@green-communications.fr>
Subject: Re: [RFC] ipv4: Do not cache routing failures due to disabled forwarding.
Date: Sat, 13 Sep 2014 14:59:30 +0200
Message-ID: <54143FB2.9000600@green-communications.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.tech.numericable.fr ([82.216.111.39]:52573 "EHLO
	smtp3.tech.numericable.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382AbaIMNJD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Sep 2014 09:09:03 -0400
Received: from gorlemagne (85-171-57-205.rev.numericable.fr [85.171.57.205])
	by smtp3.tech.numericable.fr (Postfix) with ESMTP id B2D9218123F
	for <netdev@vger.kernel.org>; Sat, 13 Sep 2014 14:59:31 +0200 (CEST)
Received: from [127.0.0.1] (localhost [127.0.0.1])
	by gorlemagne (Postfix) with ESMTP id ED262163AF1
	for <netdev@vger.kernel.org>; Sat, 13 Sep 2014 14:59:30 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Resending to netdev instead of linux-netdev, sorry again.]

For whatever reason, I didn't receive your reply and I'm not subscribed
to the list but I saw it on archives.

> 	Two alternatives are possible:
> 
> 1. set res.fi = NULL after 'no_route:' label
> 
> or better
> 
> 2. set do_cache = false after 'no_route:' label,
> then instead of 'goto local_input;' jump to a new
> label 'create_rt:' just before rt_dst_alloc.
> 
> 	Not sure, they may generate less code in the fast path.

If I implement the first alternative, GCC will optimize it to the
second. And it does not do that same optimization with my patch...

Will submit alternative 1 if there are no further issues/comments.
