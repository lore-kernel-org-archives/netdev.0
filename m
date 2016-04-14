From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Deleting child qdisc doesn't reset parent to default qdisc?
Date: Thu, 14 Apr 2016 08:01:39 -0700
Message-ID: <1460646099.10638.44.camel@edumazet-glaptop3.roam.corp.google.com>
References: <alpine.LNX.2.00.1604141638230.27368@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <jikos@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1604141638230.27368@cbobk.fhfr.pm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-04-14 at 16:44 +0200, Jiri Kosina wrote:
> Hi,
> 
> I've came across the behavior where adding a child qdisc and then deleting 
> it again makes the networking dysfunctional (I guess that's because all of 
> a sudden there is absolutely no working qdisc on the device, although 
> there originally was a default one in the parent).
> 
> In a nutshell, is this expected behavior or bug?

This is the expected behavior.

If the kernel was suddenly doing a 'replace' when you ask a delete,
then the scripts doing a delete , than a add would break.

tc users are skilled admins ;)
