From: "Rami Rosen" <roszenrami@gmail.com>
Subject: Re: [PATCH 0/2] Multicast: add mc_count to in_device and to inet6_dev
Date: Thu, 2 Oct 2008 08:24:33 +0300
Message-ID: <b25312890810012224h68a2444dob746eaf0ce80b111@mail.gmail.com>
References: <b25312890809302357j6b75dd27uced2968046c10993@mail.gmail.com>
	 <20081001.020854.146740849.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, pekkas@netcore.fi
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.168]:3481 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751914AbYJBFYe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 01:24:34 -0400
Received: by wf-out-1314.google.com with SMTP id 27so944640wfd.4
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2008 22:24:33 -0700 (PDT)
In-Reply-To: <20081001.020854.146740849.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
  - When sending the patch, I was aware that the mc_count is currently
not used (printed) in IPv6;
I added it for the sake of symmetry with IPv4 and for future use.
- Adding printing of mc_count in IPv6 is of course trivial; it was not
added not because of laziness;  I know less about IPv6 user space
tools (which read "/proc/net/igmp6") ; I was afraid that adding
printing of this mc_count field in IPv6 might break parsing of IPv6
user space tools (like netstat, etc).
So maybe this addition should be left for somebody who knows more
about IPv6 user space tools ?

Regards,
Rami Rosen


On Wed, Oct 1, 2008 at 12:08 PM, David Miller <davem@davemloft.net> wrote:
> From: "Rami Rosen" <roszenrami@gmail.com>
> Date: Wed, 1 Oct 2008 09:57:42 +0300
>
>> Hi,
>>     - This patch set adds mc_count to  struct in_device (IPv4) and to
>> struct inet6_dev (IPv6) and updates increment/decrement/initialization
>> of this field in IPv4 and in IPv6.
>>
>> - Also printing the /proc entry (/proc/net/igmp) is adjusted to use
>> the new mc_count.
>>
>>  - Thanks to David Stevens for his feedback.
>
> Why even add the mc_count to the ipv6 side if it isn't
> even going to be used?  I see nothing actually reading
> the ipv6 version of the value.
>
> If you're going to do that eventually in some later
> set of changes, add it then.
>
