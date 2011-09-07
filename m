From: Glauber Costa <glommer@parallels.com>
Subject: Re: [PATCH] per-cgroup tcp buffer limitation
Date: Tue, 6 Sep 2011 22:09:46 -0300
Message-ID: <4E66C45A.8060706@parallels.com>
References: <1315276556-10970-1-git-send-email-glommer@parallels.com> <CALdu-PDoPPdcX0bAkVpaP9R-z1yKin=JOjjT3rMuoSHJaywSCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
	<containers@lists.osdl.org>, <netdev@vger.kernel.org>,
	<xemul@parallels.com>, "David S. Miller" <davem@davemloft.net>,
	Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Paul Menage <paul@paulmenage.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:39467 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751399Ab1IGBKa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Sep 2011 21:10:30 -0400
In-Reply-To: <CALdu-PDoPPdcX0bAkVpaP9R-z1yKin=JOjjT3rMuoSHJaywSCg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/06/2011 10:08 PM, Paul Menage wrote:
> On Mon, Sep 5, 2011 at 7:35 PM, Glauber Costa<glommer@parallels.com>  wrote:
>> This patch introduces per-cgroup tcp buffers limitation. This allows
>> sysadmins to specify a maximum amount of kernel memory that
>> tcp connections can use at any point in time. TCP is the main interest
>> in this work, but extending it to other protocols would be easy.

Hi Paul,


> The general idea of limiting total socket buffer memory consumed by a
> cgroup is a fine idea, but I think it needs to be integrated more
> closely with the existing kernel memory cgroup tracking efforts,
> especially if you're trying to use as generic a name as "kmem" for it.
Can you be more specific?

The generic part of kmem cgroup in this patch is quite simple. I think 
any other patchset would have a very easy time merging things into it.
90 % is sockets.

>
> I agree with Kamezawa's comments that you need a lot more documentation.
Working on it right now.
