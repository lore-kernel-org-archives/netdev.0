From: <Narendra_K@Dell.com>
Subject: RE: [PATCH] udev: create empty regular files to represent netinterfaces
Date: Fri, 30 Oct 2009 22:23:57 +0530
Message-ID: <EDA0A4495861324DA2618B4C45DCB3EE589684@blrx3m08.blr.amer.dell.com>
References: <20091016214024.GA10091@ldl.fc.hp.com> <20091022063619.GB6321@ldl.fc.hp.com> <20091027205551.GA31963@auslistsprd01.us.dell.com> <ac3eb2510910280123g3c0e3d95wb38a239238906027@mail.gmail.com> <20091029131125.GA13809@auslistsprd01.us.dell.com> <20091029142554.GA16869@kroah.com> <20091029174600.GC3612@ldl.fc.hp.com> <EDA0A4495861324DA2618B4C45DCB3EE589682@blrx3m08.blr.amer.dell.com> <20091030160845.GA4547@lackof.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <greg@kroah.com>, <Matt_Domsch@Dell.com>, <kay.sievers@vrfy.org>,
	<linux-hotplug@vger.kernel.org>, <netdev@vger.kernel.org>,
	<Jordan_Hargrave@Dell.com>, <Charles_Rose@Dell.com>,
	<bhutchings@solarflare.com>
To: <dannf@dannf.org>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20091030160845.GA4547@lackof.org>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>> >There are two issues, which really seem distinct to me.
>> >
>> >Users expect eth0 to map to first-onboard-nic. That's an installer 
>> >issue (since the BIOS can already export this info) and I 
>agree that 
>> >if we want to "fix" that, we should fix it there.
>> >
>> 
>> I agree that installers have to be fixed in the sense that 
>they can be 
>> told to find the right interface. But, they expect determinism and 
>> depend on "eth0 to map to first-onboard-nic". Installer is 
>one of the 
>> applications that is affected by this and needs user 
>intervention, if 
>> it is not told about the right interface. I discussed 
>installer as it 
>> is so much part of a user experience.
>
>Right, but couldn't the installer do the work of scanning the 
>SMBIOS to figure out which nics are onboard, and reorder the 
>'eth*' names such that these are first? This state could then 
>be written out as udev rules so that they persist across reboots.
>

I suppose, with udev loading modules, the rules generated at runtime
could run into the problem of duplicate names, if names are reordered in
the kernel namespace. (I.e the eth* namespace). Hence idea of an
alternate namespace.

With regards,
Narendra K
