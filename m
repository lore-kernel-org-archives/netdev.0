From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 1/4] forcedeth: fix MAC address detection on network card
 (regression in 2.6.23)
Date: Fri, 09 Jan 2009 17:04:47 -0500
Message-ID: <4967C9FF.6020504@garzik.org>
References: <200901092023.n09KN72t020166@imap1.linux-foundation.org>	<4967C05A.2070509@garzik.org> <20090109133749.59c20e40.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	michael.pyne@kdemail.net, AAbdulla@nvidia.com, stable@kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34690 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758674AbZAIWEx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 17:04:53 -0500
In-Reply-To: <20090109133749.59c20e40.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Fri, 09 Jan 2009 16:23:38 -0500
> Jeff Garzik <jeff@garzik.org> wrote:
> 
>>> On Tue, 05 Feb 2008 13:20:59 -0500 Jeff Garzik <jeff@garzik.org> wrote:
>>>> NAK - this fixes one set of users, and breaks a working set of users.
>>>>
>>>> Need to add DMI check for the specific motherboard (dmi_check_system), 
>>>> and flip flag according to success/failure of that check.
>>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>> I'll just highlight this quoted bit for David...
>>
>> I've already posted a dmi_check_system() solution too
> 
> What is the status of that?  Where is it?

You were CC'd on it each time...  Here's a copy from the archives:

http://www.mail-archive.com/netdev@vger.kernel.org/msg61096.html


>> -- you just need 
>> to fill in the motherboard details to fix the regression while keeping 
>> others' systems working.
> 
> Can you please tell Michael what info is needed to wrap this up?  And
> how he is to obtain it?

I think he posted dmidecode output.

I also think he said a BIOS update fixed the problem, at least according 
to the mail thread.

	Jeff


