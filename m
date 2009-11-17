From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: [PATCH] e1000e: Fix usage under kexec
Date: Tue, 17 Nov 2009 14:28:54 -0700
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FA68EE90F@rrsmsx501.amr.corp.intel.com>
References: <4AF87AB1.1070603@anduras.de> <4B026B24.5040108@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev <netdev@vger.kernel.org>
To: Stefan Assmann <sassmann@redhat.com>, Sven Anders <sven@anduras.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:43745 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752848AbZKQV2u convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 16:28:50 -0500
In-Reply-To: <4B026B24.5040108@redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefan Assmann wrote:
> On 09.11.2009 21:25, Sven Anders wrote:
>> Hello!
>> 
>> We're experiencing the following problem:
>> 
>> We start a minimal linux system, prepare the system and start the
>> final system via kexec. On two different systems (one with a 82573
>> and one with a 82574), the driver cannot initialize the network
>> hardware, because the PHY is not recognized. 
>> 
>> We get the following error:
>>   e1000e: probe of 0000:02:00.0 failed with error -2
> 
> Hi Sven,
> 
> have a look at the following thread, it seems very similar.
> http://kerneltrap.org/mailarchive/linux-netdev/2009/3/7/5114394
> 
>   Stefan
> --
> Stefan Assmann         | Red Hat GmbH
> Software Engineer      | Otto-Hahn-Strasse 20, 85609 Dornach
>                        | HR: Amtsgericht Muenchen HRB 153243
>                        | GF: Brendan Lane, Charlie Peters,
> sassmann at redhat.com |     Michael Cunningham, Charles Cachera

But there is already similar code in e1000e:
http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commit;h=4f9de721ab73a5271a79b126f7b5140b01a05c99