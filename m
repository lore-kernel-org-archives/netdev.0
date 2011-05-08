From: Alex Bligh <alex@alex.org.uk>
Subject: Re: Scalability of interface creation and deletion
Date: Sun, 08 May 2011 09:08:30 +0100
Message-ID: <4C6EBDC32B7CEC8768A223C5@nimrod.local>
References: <891B02256A0667292521A4BF@Ximines.local>	
 <1304770926.2821.1157.camel@edumazet-laptop>	
 <0F4A638C2A523577CDBC295E@Ximines.local>	
 <1304783684.9216.2.camel@edumazet-laptop>	
 <4DC571F1.2020108@candelatech.com>	
 <1304786277.3207.12.camel@edumazet-laptop>	
 <4DC57702.4090606@candelatech.com>
 <1304787065.3207.17.camel@edumazet-laptop>
 <4DC611C3.7070607@candelatech.com>
Reply-To: Alex Bligh <alex@alex.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alex Bligh <alex@alex.org.uk>
To: Ben Greear <greearb@candelatech.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.avalus.com ([89.16.176.221]:36426 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751361Ab1EHIIb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 May 2011 04:08:31 -0400
In-Reply-To: <4DC611C3.7070607@candelatech.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



--On 7 May 2011 20:45:07 -0700 Ben Greear <greearb@candelatech.com> wrote:

> Well, I'd hope to get a netlink message about the device being deleted,
> and
> after that, be able to create another one with the same name, etc.
>
> Whether the memory is actually freed in the kernel or not wouldn't matter
> to me...

Provided the former para is always done, I can't actually think of a case
where the caller would /ever/ care about the latter (save perhaps
a final shutdown of the whole net subsystem).

-- 
Alex Bligh
