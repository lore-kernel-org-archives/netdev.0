From: Petr Cvek <petr.cvek@tul.cz>
Subject: Re: [PATCH 2/3] net: irda: pxaficp_ir: convert to readl and writel
Date: Sun, 13 Sep 2015 04:47:51 +0200
Message-ID: <55F4E3D7.2000106@tul.cz>
References: <1441261251-19548-1-git-send-email-robert.jarzmik@free.fr>
 <1441261251-19548-3-git-send-email-robert.jarzmik@free.fr>
 <55EF43E9.2040000@tul.cz> <55EF8A0F.7070106@tul.cz>
 <87twr4un1h.fsf@belgarion.home> <55F11FDE.6050304@tul.cz>
 <87io7iv845.fsf@belgarion.home> <55F233D2.3020708@tul.cz>
 <87y4gdtr6e.fsf@belgarion.home> <55F3A798.5090904@tul.cz>
 <87d1xnucfi.fsf@belgarion.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Cc: zonque@gmail.com, ulf.hansson@linaro.org,
	Samuel Ortiz <samuel@sortiz.org>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
To: Robert Jarzmik <robert.jarzmik@free.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87d1xnucfi.fsf@belgarion.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dne 12.9.2015 v 13:03 Robert Jarzmik napsal(a):
> Petr Cvek <petr.cvek@tul.cz> writes:
> 
>>>>> And it is true I have not tested the rootfs special case, where drivers are not
>>>>> yet initialized (and more specifically gpio and interrupt chip). Your backtrace
>>>>> should tell me if you fall into this category of issues ... but I digress, this
>>>>> has no link with pxaficp.
>>>>
>>>> Should I start new thread? (same bug can be present in the FICP too)
>>> Yes, this pxamci bothers me, it deserves a thread.
>>
>> Will start soon.
> And I think I see your problem now :
>   (a) there is a regression from the commit 8c8fe97b2b8a, for which the fix is
>   here: https://lkml.org/lkml/2015/9/6/112
>   (b) for gpio expanders, another fix is here :
>   https://lkml.org/lkml/2015/9/12/62
> 
> The regression is on dmaengine, that's where the thread belongs I think, at
> least if that fixes your issue.
> 
Great now it finally boots. Thanks.

Petr
