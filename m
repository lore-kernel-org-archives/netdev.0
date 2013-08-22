From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: Re: [PATCH] netns: unix: only allow to find out unix socket in same
 net namespace
Date: Thu, 22 Aug 2013 09:36:35 +0800
Message-ID: <52156B23.7050208@cn.fujitsu.com>
References: <1377059473-25526-1-git-send-email-gaofeng@cn.fujitsu.com> <87d2p7vcdx.fsf@xmission.com> <5214641C.9030902@cn.fujitsu.com> <87wqnfttdf.fsf@xmission.com> <52146AC2.5070409@cn.fujitsu.com> <87haejtjet.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, systemd-devel@lists.freedesktop.org,
	lxc-devel@lists.sourceforge.net, davem@davemloft.net,
	Linux Containers <containers@lists.linux-foundation.org>,
	"libvir-list@redhat.com" <libvir-list@redhat.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:2128 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752462Ab3HVCUf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Aug 2013 22:20:35 -0400
In-Reply-To: <87haejtjet.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/21/2013 06:42 PM, Eric W. Biederman wrote:
> Gao feng <gaofeng@cn.fujitsu.com> writes:
> 
>> right now I only take note of the unix socket /run/systemd/private,
>> but there may have many similar unix sockets, they can exist in any
>> path. the strange problems will still happen.
> 
> It could just as easily have been a fifo in the filesystem, and the
> result would have been the same.
> 
> The network namespace are all about communicating between network
> namespaces and that is what was allowed here.
> 
> If you don't want a socket or a fifo or any other file to be used by a
> container don't give it access to it.  It really is that simple.
> 

Hmm, I tend to think you are right...

Thanks!
