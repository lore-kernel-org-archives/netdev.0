From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH v4] net/bonding: send arp in interval if no active slave
Date: Fri, 09 Oct 2015 10:36:03 -0400
Message-ID: <5617D0D3.90208@redhat.com>
References: <56094137.9030206@redhat.com> <1444161197-38442-1-git-send-email-jarod@redhat.com> <56150A1B.10405@cumulusnetworks.com> <56151E4A.2000503@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Uwe Koziolek <uwe.koziolek@redknee.com>,
	Jay Vosburgh <jay.vosburgh@canonical.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Veaceslav Falico <vfalico@gmail.com>, netdev@vger.kernel.org
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56151E4A.2000503@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarod Wilson wrote:
...
> As Andy already stated I'm not a fan of such workarounds either but it's
> necessary sometimes so if this is going to be actually considered then a
> few things need to be fixed. Please make this a proper bonding option
> which can be changed at runtime and not only via a module parameter.

Is there any particular userspace tool that would need some updating, or 
is adding the sysfs knobs sufficient here? I think I've got all the 
sysfs stuff thrown together now, but still need to test.


>> Now, I saw that you've only tested with 500 ms, can't this be fixed by
>> using
>> a different interval ? This seems like a very specific problem to have a
>> whole new option for.
>
> ...I'll wait until we've heard confirmation from Uwe that intervals
> other than 500ms don't fix things.

Okay, so I believe the "only tested with 500ms" was in reference to 
testing with Uwe's initial patch. I do have supporting evidence in a 
bugzilla report that shows upwards of 5000ms still experience the 
problem here.



-- 
Jarod Wilson
jarod@redhat.com
