From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [Xen-devel] [PATCH v6] xen/grant-table: Avoid m2p_override during
 mapping
Date: Mon, 3 Feb 2014 14:27:25 +0100
Message-ID: <52EF993D.1000701@citrix.com>
References: <1390512224-27296-1-git-send-email-zoltan.kiss@citrix.com>	<alpine.DEB.2.02.1401232333280.15917@kaball.uk.xensource.com>	<52EE1E26.2040308@linaro.org> <52EE93F0.1020508@citrix.com> <52EF7618.7030402@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Julien Grall <julien.grall@linaro.org>,
	Stefano Stabellini <stefano.stabellini@eu.citrix.com>,
	<jonathan.davies@citrix.com>, <wei.liu2@citrix.com>,
	<ian.campbell@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <xen-devel@lists.xenproject.org>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52EF7618.7030402@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/02/14 11:57, David Vrabel wrote:
>>
>> Hi,
>>
>> That's bad indeed. I think the best solution is to put those parts
>> behind an #ifdef x86. The ones moved from x86/p2m.c to grant-table.c.
>> David, Stefano, what do you think?
> I don't think we want (more) #ifdef CONFIG_X86 in grant-table.c and the
> arch-specific bits will have to factored out into their own functions
> with suitable stubs provided for ARM.
>
I've just sent in v7 with stubs, I guess that's something you suggested. 
Please review it, I'm especially curious about your thoughts regarding 
the new function name.

Zoli
