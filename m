From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Subject: Re: skbuff bug?
Date: Tue, 26 Aug 2008 03:17:09 -0700
Message-ID: <9929d2390808260317l2fb17bcxe099e85fcf5bb939@mail.gmail.com>
References: <86802c440808202056j6cfe5ca0v6284140ae4b9b8cd@mail.gmail.com>
	 <86802c440808211646y758cfdd7n505777b2b8b58c9a@mail.gmail.com>
	 <20080826091752.GB5822@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Yinghai Lu" <yhlu.kernel@gmail.com>,
	"David Miller" <davem@davemloft.net>,
	"Jeff Garzik" <jeff@garzik.org>, "Ingo Molnar" <mingo@elte.hu>,
	"Bruce Allan" <bruce.w.allan@intel.com>,
	netdev <netdev@vger.kernel.org>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>
To: "Evgeniy Polyakov" <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:44025 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753851AbYHZKRK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 06:17:10 -0400
Received: by wf-out-1314.google.com with SMTP id 27so2259642wfd.4
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 03:17:09 -0700 (PDT)
In-Reply-To: <20080826091752.GB5822@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 26, 2008 at 2:17 AM, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> Hi.
>
> On Thu, Aug 21, 2008 at 04:46:49PM -0700, Yinghai Lu (yhlu.kernel@gmail.com) wrote:
>> it seems caused by
>>
>> commit f8d59f7826aa73c5e7682fbed6db38020635d466
>> Author: Bruce Allan <bruce.w.allan@intel.com>
>> Date:   Fri Aug 8 18:36:11 2008 -0700
>>
>>     e1000e: test for unusable MSI support
>
> Intel folks seems to be on vacations or whatever else without access to
> the mail. Can you confirm that bug still exists in the latest tree and
> reverting this commit fixes the problem?
>
> --
>        Evgeniy Polyakov
> --

We are looking into the issue, I am sorry there has been no response until now.

I am still curious if you still see the issue with all the recent
changes.  Please provide the device id you are using and system info
so that we can try and reproduce the issue, if the issue persists with
the latest git tree.

-- 
Cheers,
Jeff
