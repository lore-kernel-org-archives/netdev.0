From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [patch (for 2.6.25?) 1/3] e100: do suspend/shutdown like e1000
Date: Tue, 04 Mar 2008 15:44:21 -0800
Message-ID: <47CDDED5.2040207@intel.com>
References: <200803042258.m24MwfoZ001397@imap1.linux-foundation.org>	<47CDD54A.60101@intel.com> <20080304153330.fd224258.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, arvidjaar@mail.ru
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:22309 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753204AbYCDXsO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2008 18:48:14 -0500
In-Reply-To: <20080304153330.fd224258.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Tue, 04 Mar 2008 15:03:38 -0800
> "Kok, Auke" <auke-jan.h.kok@intel.com> wrote:
> 
>> akpm@linux-foundation.org wrote:
>>> From: "Kok, Auke" <auke-jan.h.kok@intel.com>
>>>
>>> This fixes a "trying to free already free IRQ" message and simplifies the
>>> shutdown/suspend code by re-using already existing code when going to
>>> suspend.  The code is now symmetric with e100_resume.
>>>
>>> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
>>> Tested-by: Andrey Borzenkov <arvidjaar@mail.ru>
>>> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>>
>> This should already be in jeff's inbox ...
>>
> 
> It's been two weeks nearly - Jeff's inbox might have sprunk a leak ;)
> 
> There are lots of leaky inboxes - I have just finished spraying nearly 200
> dribbles at various maintainers.

lol, I actually did not send this to jeff until yesterday myself, so you can blame
my inbox for being slow, not Jeff in this case ;)

Auke
