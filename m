From: "Mark Wallis" <mwallis@serialmonkey.com>
Subject: RE: Hardware button support for Wireless cards
Date: Tue, 16 May 2006 13:10:42 +1000
Message-ID: <!&!AAAAAAAAAAAuAAAAAAAAAFjEWUvexJtFsm0woXMZeHABAC4qy2+Ja65JmQuhL0/hqcgAAAAARPYAABAAAACMsnpvfH4iTKrBh6ONAHj7AQAAAAA=@serialmonkey.com>
References: <20060515162045.GA10717@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "'Dan Williams'" <dcbw@redhat.com>, <netdev@vger.kernel.org>,
	"'David Zeuthen'" <davidz@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qvfw1.qvalent.com ([202.7.65.65]:37578 "EHLO mail.qvalent.com")
	by vger.kernel.org with ESMTP id S1751093AbWEPDLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 May 2006 23:11:22 -0400
To: "'Jouni Malinen'" <jkm@devicescape.com>,
	"'Ivo van Doorn'" <ivdoorn@gmail.com>
In-Reply-To: <20060515162045.GA10717@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 16, 2006, Jouni Malinen wrote:

> Some hardware designs disable the radio in hardware, some 
> don't.. In other words, the behavior would not be consistent 
> between hardware designs unless the radio would be disabled 
> unconditionally in software-processed case. I would like to 
> be able to trust on the rfkill to really kill the radio 
> regardless of whether the user space mechanism is in place or 
> not, i.e., I see this as a function that can be used to 
> disable radio in environments were use of wireless devices is 
> not allowed for some reason.
> 
> Sending an event to user space would be a good additional 
> indication that the radio was disabled. If user space wants 
> to do something first, I would think that doing this with 
> full software control (i.e., not depending on any particular 
> hardware button and just having a UI mechanism for triggering 
> this) would allow more consistent behavior.

Sounds like this is the popular option - I agree that immediate
radio-off is the "safe" way to go here as at least the driver
can guarantee that the radio is disabled no matter the userspace
config.

Does someone want to put their hand up and specify the userspace
interface here and now so we all keep to a standard ? Working
as an input device as David suggested seems to give us the most
flexibility.

Regards,

Mark Wallis
E: mwallis@serialmonkey.com


