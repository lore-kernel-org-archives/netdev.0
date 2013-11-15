From: John Hughes <john@atlantech.com>
Subject: Re: When a TCP segment is split up (to be sent through a TUN device
 with a small MTU) who should recalculate the checksum?
Date: Fri, 15 Nov 2013 15:55:11 +0100
Message-ID: <528635CF.9050306@atlantech.com>
References: <5285E0BC.4090402@atlantech.com> <52862DBF.2060801@gmail.com> <5286305F.5060903@atlantech.com> <528632AA.2090400@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Hughes <john@atlantech.com>,
	Vlad Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org
To: vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from olympic.calvaedi.com ([89.202.194.163]:47883 "EHLO
	olympic.calvaedi.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104Ab3KOOzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 09:55:19 -0500
In-Reply-To: <528632AA.2090400@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15/11/13 15:41, Vlad Yasevich wrote:
> On 11/15/2013 09:31 AM, John Hughes wrote:
>> On 15/11/13 15:20, Vlad Yasevich wrote:
>>>
>>> Can you check to see if you have the following patch in your kernel
>>> commit: 1cdbcb7957cf9e5f841dbcde9b38fd18a804208b

> Give it a try.  It has helped me in similar situations.  If it helps,
> we can get it into the stable tree.

Ok, I'll make myself a kernel with that patch.

Should be able to try it over the weekend.

-- 
John.
