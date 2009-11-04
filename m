From: "J. K. Cliburn" <jcliburn@gmail.com>
Subject: Re: [atl1-devel] [Bugme-new] [Bug 14431] New: atl1 eth0 link continuously down up
Date: Tue, 3 Nov 2009 18:19:37 -0600
Message-ID: <1A6E85E5-8C3B-4674-9C7B-54740D065171@gmail.com>
References: <bug-14431-10286@http.bugzilla.kernel.org/> <20091102224018.e306b12f.akpm@linux-foundation.org>
Mime-Version: 1.0 (Apple Message framework v753.1)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: atl1-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	johan_vdp@hotmail.com, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f202.google.com ([209.85.211.202]:53966 "EHLO
	mail-yw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752585AbZKDATo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 19:19:44 -0500
Received: by ywh40 with SMTP id 40so5916217ywh.33
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2009 16:19:49 -0800 (PST)
In-Reply-To: <20091102224018.e306b12f.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Nov 3, 2009, at 12:40 AM, Andrew Morton wrote:

>
> (switched to email.  Please respond via emailed reply-to-all, not  
> via the
> bugzilla web interface).
>
> On Sat, 17 Oct 2009 19:17:38 GMT bugzilla- 
> daemon@bugzilla.kernel.org wrote:
>
>> http://bugzilla.kernel.org/show_bug.cgi?id=14431
>>
>>            Summary: atl1 eth0 link continuously down up
>>            Product: Drivers
>>            Version: 2.5
>>     Kernel Version: 2.6.30.8-64.fc11.x86_64
>>           Platform: All
>>         OS/Version: Linux
>>               Tree: Mainline
>>             Status: NEW
>>           Severity: normal
>>           Priority: P1
>>          Component: Network
>>         AssignedTo: drivers_network@kernel-bugs.osdl.org
>>         ReportedBy: johan_vdp@hotmail.com
>>         Regression: No
>>
>>
>> /var/log/messages shows
>> ..
>> Oct 17 21:06:01 blauw kernel: atl1 0000:01:00.0: eth0 link is down
>> Oct 17 21:06:01 blauw kernel: atl1 0000:01:00.0: eth0 link is up  
>> 100 Mbps full
>> duplex

Strange.  This driver hasn't been changed in quite some time and it's  
very stable.  I'm running Fedora 11 and I don't see the problem at all.

I note that your NIC is autonegotiating to only 100 Mbps instead of  
1000 Mbps; is your switch a 100 Mbps device?

Out of curiosity, are you running with or without NetworkManager active?

Increase the verbosity of driver messages and see if any additional  
light is shed on the subject.

ethtool -s eth0 msglvl 0xffff


Jay Cliburn



