From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 09/14] i40e: Enable all PCTYPEs except FCOE for RSS.
Date: Sun, 08 Dec 2013 00:20:41 +0300
Message-ID: <52A39129.7090507@cogentembedded.com>
References: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>		 <1386382643-29055-10-git-send-email-jeffrey.t.kirsher@intel.com>		 <52A36235.1040406@cogentembedded.com>	 <1386440208.2195.3.camel@jtkirshe-mobl>	 <52A3812F.4070701@cogentembedded.com> <1386444985.2195.8.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:35039 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753808Ab3LGUUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Dec 2013 15:20:40 -0500
Received: by mail-lb0-f169.google.com with SMTP id y6so807390lbh.0
        for <netdev@vger.kernel.org>; Sat, 07 Dec 2013 12:20:39 -0800 (PST)
In-Reply-To: <1386444985.2195.8.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/07/2013 10:36 PM, Jeff Kirsher wrote:

>>>>> From: Anjali Singhai Jain <anjali.singhai@intel.com>

>>>>> RSS can steer packets based on recognition of all
>>>>> sorts of different headers.  Enable some more of them.

>>>>> Change-Id: I2264dedae66fb0bceca6fb6e772e050e3ca8efc8

>>>>       This line has no place in the upstream patches, and I'm seeing it
>>>> in several patches of this series.

>>> This is an internal hash id, so that we can track upstream changes back
>>> to internal git tree changes.  I did verify that this was acceptable and
>>> is being used in the kernel in upstream patches before pushing this
>>> information.

>>      First time I hear about that. Its use is constantly denied in
>> linux-usb at least.  Maybe netdev has its own rules regarding this though...

    Greg KH seems to be persistent in being negative towards its use. I also 
react semi-automatically whenever I see it, asking to remove it. Anyway, it's 
really DaveM's issue whether to allow it.
    The main issue with it is that it doesn't contain any useful information 
to an ordinary person browsing kernel commits, it's exactly for the internal 
use only.

> Take a look at `git log --format=oneline --grep="Change-Id"`
> You will see there are instances in arch as well as in wireless and in
> other areas as well.

    I saw only 3 screens of commits (expected to see more) without much system.

> So we are not doing something new or the only ones using this tag.

    I didn't say that (in fact, quite the contrary).

> Google appears to be using it as well based the following information:
> https://gerrit-documentation.storage.googleapis.com/Documentation/2.7/user-changeid.html

    Why should we care about what Google does?

> Places using gerrit:
> http://code.google.com/p/gerrit/wiki/ShowCases
> This is the largest example of a "Change-Id:" tag that I know of.

    I didn't see the Linux kernel in this list, only Android.

WBR, Sergei
