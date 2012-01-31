From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: network regression: cannot rename netdev twice
Date: Tue, 31 Jan 2012 12:17:16 +0100
Message-ID: <4F27CDBC.5020201@suse.cz>
References: <4F27120A.4040106@suse.cz> <CAPXgP12Sr2KzGJ9RA13QBOCkctb-z3O4+1uHOjANgMDDv2pxaQ@mail.gmail.com> <4F27C54F.1010107@suse.cz> <CAPXgP11=U_Y3LvJB2LRnXQ53y1WQQTqc0j1c7iva6ZXvF97wEw@mail.gmail.com> <4F27C9D4.3040105@suse.cz> <CAPXgP12pj6esZVmN-PYTVgJ+_MaAfmpa9hKoKKQZ+Y=Y-Kb4eA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Greg KH <greg@kroah.com>, LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAPXgP12pj6esZVmN-PYTVgJ+_MaAfmpa9hKoKKQZ+Y=Y-Kb4eA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/31/2012 12:13 PM, Kay Sievers wrote:
>>> Does is work, if you rename the devices to something else than ethX?
>>
>> Negative:
>> # ip link set eth0 name krtek
>> # ip link set krtek name jezek
>> RTNETLINK answers: No such file or directory
> 
> This is a command sequence you type manually?

Yea, and it is working with 3.3.0-rc1-next-20120124_64+. Not with
3.3.0-rc1-next-20120131_64+.

> You are sure that userspace is not working in the background,
> triggered by uevents, and comes into your way here?

Note that krtek exists after the first command. But cannot be renamed
further.

thanks,
-- 
js
suse labs
