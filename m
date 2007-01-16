From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH 0/59] Cleanup sysctl
Date: Tue, 16 Jan 2007 11:15:05 -0800
Message-ID: <45AD2439.6000406@zytor.com>
References: <m1ac0jc4no.fsf@ebiederm.dsl.xmission.com>	<45AD02FF.605@zytor.com> <m164b6den7.fsf@ebiederm.dsl.xmission.com>	<45AD1AD7.7030804@zytor.com>	<m1ac0iby5q.fsf@ebiederm.dsl.xmission.com>	<45AD2042.9090701@zytor.com> <m164b6bxpz.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>,
	Tony Luck <tony.luck@intel.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([192.83.249.54]:39238 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051AbXAPTPy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jan 2007 14:15:54 -0500
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <m164b6bxpz.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
>>
>> Agreed.  *Furthermore*, if the number isn't in <linux/sysctl.h> it shouldn't
>> exist anywhere else, either.
> 
> That would be a good habit.  Feel free to send the patches to ensure that
> is so.
> 
> I'm a practical fix it when it is in my way kind of guy ;)

That's fine.  However, I am wondering if there are things in 
<linux/sysctl.h> which really doesn't need architectural numbers, i.e. 
which should be removed from the binary interface.

	-hpa
