From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH v2.6.26 0/2] Dynamic TBIPA for gianfar
Date: Wed, 16 Apr 2008 08:31:10 -0500
Message-ID: <6C1D456C-0E5B-4D1A-8162-C91BFB7D2821@kernel.crashing.org>
References: <1208276601-16964-1-git-send-email-paul.gortmaker@windriver.com> <18437.18289.944128.351533@cargo.ozlabs.ibm.com> <7d1d9c250804151857x65cf14cfxe6dc5696505631c7@mail.gmail.com> <6C6E8854-3F7A-4661-A5F3-B7CA8676A11A@kernel.crashing.org> <4805FBD2.6010101@windriver.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@gmail.com>,
	Paul Mackerras <paulus@samba.org>,
	"linuxppc-dev@ozlabs.org list" <linuxppc-dev@ozlabs.org>,
	netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:50075 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758740AbYDPNbV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 09:31:21 -0400
In-Reply-To: <4805FBD2.6010101@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Apr 16, 2008, at 8:14 AM, Paul Gortmaker wrote:
> Kumar Gala wrote:
>>
>> On Apr 15, 2008, at 8:57 PM, Paul Gortmaker wrote:
>>> On Tue, Apr 15, 2008 at 8:25 PM, Paul Mackerras <paulus@samba.org>  
>>> wrote:
>>>> Paul Gortmaker writes:
>>>>
>>>>> This is the resend of the two patches as per Andy's request for  
>>>>> v2.6.26
>>>>> that allow boards with a PHY at the end of the bus to function,  
>>>>> by having
>>>>> the TBIPA set dynamically.  The 1st patch factors out some of  
>>>>> the PHY
>>>>> probe code so it can be recycled by the TBIPA probe, and the  
>>>>> second patch
>>>>> implements the dynamic probe itself.
>>>>
>>>> I notice that these two patches only touch drivers/net and
>>>> include/linux.  If you want these to go upstream into Linus'  
>>>> tree, you
>>>> will need to send them to Jeff Garzik and the netdev list.  Posting
>>>> them to the linuxppc-dev list is fine for getting them reviewed but
>>>> isn't a path to upstream.
>>>
>>> Yep, they have already been sent to Jeff/netdev earlier today as  
>>> well.
>>> I'd inadvertently left them off the CC but Andy reminded me already.
>>>
>>> Thanks,
>>> Paul.
>>
>> these should get an Ack by Andy before going in to any tree.
>
> Andy has already done that, so I think we should be good to go.
>
> http://ozlabs.org/pipermail/linuxppc-dev/2008-April/054572.html

Cool.  I'm guessing these will go via jeff's tree for 2.6.26?

- k
