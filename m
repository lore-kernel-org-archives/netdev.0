From: Daniel Drake <dsd@gentoo.org>
Subject: Re: Please pull 'upstream' branch of wireless-2.6
Date: Wed, 17 May 2006 22:23:34 +0100
Message-ID: <446B9456.5030308@gentoo.org>
References: <20060517193405.GB17895@tuxdriver.com> <20060517193801.GC17895@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta08-winn.ispmail.ntl.com ([81.103.221.48]:18938 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1751125AbWEQVFz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 May 2006 17:05:55 -0400
To: jeff@garzik.org, netdev@vger.kernel.org, arjan@linux.intel.com,
	dsd@gentoo.org
In-Reply-To: <20060517193801.GC17895@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

John W. Linville wrote:
> Daniel Drake:
>       set_security implementation inside softmac

If it's not too late, can you drop this one?

I didn't receive any feedback on it, and I decided it's not the right 
approach. The interface isn't great, but when done at the driver level 
it allows drivers to reject various security settings that they don't 
support by not copying them into secinfo.

So, even though this code block will be almost duplicated over bcm43xx, 
zd1211, and more, I think that level is the right place to put it.

Thanks,
Daniel
