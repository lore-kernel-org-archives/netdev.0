From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH v2.6.26 0/2] Dynamic TBIPA for gianfar
Date: Wed, 16 Apr 2008 09:14:58 -0400
Message-ID: <4805FBD2.6010101@windriver.com>
References: <1208276601-16964-1-git-send-email-paul.gortmaker@windriver.com> <18437.18289.944128.351533@cargo.ozlabs.ibm.com> <7d1d9c250804151857x65cf14cfxe6dc5696505631c7@mail.gmail.com> <6C6E8854-3F7A-4661-A5F3-B7CA8676A11A@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@gmail.com>,
	Paul Mackerras <paulus@samba.org>,
	"linuxppc-dev@ozlabs.org list" <linuxppc-dev@ozlabs.org>,
	netdev@vger.kernel.org
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:61543 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754824AbYDPNO5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 09:14:57 -0400
In-Reply-To: <6C6E8854-3F7A-4661-A5F3-B7CA8676A11A@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kumar Gala wrote:
>
> On Apr 15, 2008, at 8:57 PM, Paul Gortmaker wrote:
>> On Tue, Apr 15, 2008 at 8:25 PM, Paul Mackerras <paulus@samba.org> 
>> wrote:
>>> Paul Gortmaker writes:
>>>
>>>> This is the resend of the two patches as per Andy's request for 
>>>> v2.6.26
>>>> that allow boards with a PHY at the end of the bus to function, by 
>>>> having
>>>> the TBIPA set dynamically.  The 1st patch factors out some of the PHY
>>>> probe code so it can be recycled by the TBIPA probe, and the second 
>>>> patch
>>>> implements the dynamic probe itself.
>>>
>>> I notice that these two patches only touch drivers/net and
>>> include/linux.  If you want these to go upstream into Linus' tree, you
>>> will need to send them to Jeff Garzik and the netdev list.  Posting
>>> them to the linuxppc-dev list is fine for getting them reviewed but
>>> isn't a path to upstream.
>>
>> Yep, they have already been sent to Jeff/netdev earlier today as well.
>> I'd inadvertently left them off the CC but Andy reminded me already.
>>
>> Thanks,
>> Paul.
>
> these should get an Ack by Andy before going in to any tree.

Andy has already done that, so I think we should be good to go.

http://ozlabs.org/pipermail/linuxppc-dev/2008-April/054572.html

Paul.

>
> - k

