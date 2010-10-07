From: Kay Sievers <kay.sievers@vrfy.org>
Subject: Re: [PATCH V2] Use firmware provided index to register a network interface
Date: Thu, 7 Oct 2010 19:13:31 +0200
Message-ID: <AANLkTi=1fuwDpJ_RafhQ2sMZRqSaikqAQAOC=UYCUknN@mail.gmail.com>
References: <20101007142319.GB2641@libnet-test.oslab.blr.amer.dell.com>
 <20101007151134.GA25713@kroah.com> <20101007163113.GA14260@auslistsprd01.us.dell.com>
 <20101007164906.GB122295@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Matt Domsch <Matt_Domsch@dell.com>, Greg KH <greg@kroah.com>,
	Narendra_K@dell.com, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, linux-pci@vger.kernel.org,
	Jordan_Hargrave@dell.com, Vijay_Nijhawan@dell.com,
	Charles_Rose@dell.com
To: David Lamparter <equinox@diac24.net>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20101007164906.GB122295@jupiter.n2.diac24.net>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 7, 2010 at 18:49, David Lamparter <equinox@diac24.net> wrote:
> On Thu, Oct 07, 2010 at 11:31:13AM -0500, Matt Domsch wrote:
>> At most, they'll have to deal with the same "eth0_rename"
>
> Getting that "eth0_rename" stuff is not something unchangeably imposed
> by the kernel. I think this should be considered an udev bug most of all
> things, since if the udev scripts did it right, this wouldn't happen. A
> "right" way to do this would for example be to first rename all devices
> to "tmpwhatever0", then rename them back to their proper ethX names.

Whats the difference between eth0_rename and tmpeth0? I don't see any. :)

> Now I don't know even a single bit about udev scripting, so maybe this
> isn't possible with the current udev infrastructure, but there's
> certainly no kernel part stopping a proper implementation.
>
> Btw, what happened to nameif(8)? It's totally outdated (and deprecated I
> guess?), but it got the job done...

It can't swap already taken device names on hotplug, and that job
might get complicated very easily. Also stuff needs to be renamed
before the device is announced to userspace, otherwise the interface
gets configured and can't be renamed anymore.

Kay
