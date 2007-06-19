From: jamal <hadi@cyberus.ca>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Tue, 19 Jun 2007 12:20:06 -0400
Message-ID: <1182270006.4968.62.camel@localhost>
References: <1179827251.7707.29.camel@localhost.localdomain>
	 <1179831825.4121.30.camel@localhost>
	 <1180258853.7707.53.camel@localhost.localdomain>
	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>
	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>
	 <1181811576.5411.27.camel@localhost.localdomain>
	 <1181820510.4091.9.camel@localhost>
	 <1181869285.5411.39.camel@localhost.localdomain>
	 <1182178882.4063.11.camel@localhost>
	 <1182252616.21013.12.camel@johannes.berg>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Zhang Rui <rui.zhang@intel.com>, netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1182252616.21013.12.camel@johannes.berg>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-19-06 at 13:30 +0200, Johannes Berg wrote:

> Ah, that coincides with something I was wondering about. Isn't it
> possible to have multiple multicast groups with generic netlink? If so,
> we might have to use real netlink for wireless...


There is one default mcast group per entity. Most users only need that
one.
If you need more, we go one of two ways:
a) Register for multiple IDs with the code as is. 
b) we could add a "reserve multicast group" interface in the kernel.

Thoughts?

cheers,
jamal

