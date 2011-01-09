From: Iain Paton <selsinork@gmail.com>
Subject: Re: 2.6.37 vlans on bnx2 not functional, panic with tcpdump
Date: Sun, 09 Jan 2011 11:22:39 +0000
Message-ID: <4D299A7F.40604@gmail.com>
References: <4D2634DE.2060907@gmail.com> <1294357941.21580.2.camel@HP1> <1294361206.21580.7.camel@HP1> <AANLkTi=PGPVRbS3XViskpZ0GSS8ouBcgVZYYG9EoM-Nz@mail.gmail.com> <1294422653.14051.11.camel@HP1> <4D2754F9.8050707@gmail.com> <4D28AFD1.3020808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D28AFD1.3020808@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> Iain Paton wrote:
> ...
>> So you can consider any bnx2 cause for this closed. I'll get back to the
>> list if I can come up with any more useful info.
> 
> Hi Iain,
> If it's not a problem, please try if the attached debugging patch
> (not tested) can change anything.

No problem testing with the patch installed, however I'm now unable to duplicate the problem with a rebuilt kernel, with or without 
the patch.

The original kernel build I did still fails repeatably, but something as simple as erasing the directory, unpacking the same source 
tarball and re-compiling using the same config file gets me a working kernel.

This is somewhat troubling as there must have been some initial cause, but I'm unable to pin it down. Have spent the last day or so 
checking toolchain versions, running hardware tests on the physical build server and have come up completely empty.

I think we can safely ignore this now as it appears to be a one-off bad compile, for reasons unknown, but totally unrepeatable.

Thanks to all for your help, and apologies for the noise.

Iain
