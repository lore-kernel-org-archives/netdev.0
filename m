From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 7/7] sysfs: @name comes before @ns
Date: Wed, 11 Sep 2013 20:39:27 -0700
Message-ID: <87a9ji4sk0.fsf@xmission.com>
References: <1378952949-7900-1-git-send-email-tj@kernel.org>
	<1378952949-7900-8-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	kay@vrfy.org, netdev@vger.kernel.org, lizefan@huawei.com
To: Tejun Heo <tj@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:53710 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757630Ab3ILDjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 23:39:36 -0400
In-Reply-To: <1378952949-7900-8-git-send-email-tj@kernel.org> (Tejun Heo's
	message of "Wed, 11 Sep 2013 22:29:09 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tejun Heo <tj@kernel.org> writes:

> Some internal sysfs functions which take explicit namespace argument
> are weird in that they place the optional @ns in front of @name which
> is contrary to the established convention.  This is confusing and
> error-prone especially as @ns and @name may be interchanged without
> causing compilation warning.
>
> Swap the positions of @name and @ns in the following internal
> functions.

Nacked-by: "Eric W. Biederman" <ebiederm@xmission.com>

@ns is more significant so it should come first.

Where do we have the backwards convention of putting @name first?

Eric
