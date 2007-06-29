From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Fri, 29 Jun 2007 15:11:26 +0200
Message-ID: <468504FE.9000502@trash.net>
References: <1179827251.7707.29.camel@localhost.localdomain>	 <1179831825.4121.30.camel@localhost>	 <1180258853.7707.53.camel@localhost.localdomain>	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>	 <1181811576.5411.27.camel@localhost.localdomain>	 <1181820510.4091.9.camel@localhost>	 <1181869285.5411.39.camel@localhost.localdomain>	 <1182178882.4063.11.camel@localhost>	 <1182223964.5411.76.camel@localhost.localdomain>	 <1182811210.6644.22.camel@johannes.berg>	 <1182986681.5155.55.camel@localhost> <1183121869.4089.57.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Zhang Rui <rui.zhang@intel.com>,
	netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1183121869.4089.57.camel@johannes.berg>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> On Wed, 2007-06-27 at 19:24 -0400, jamal wrote:
> 
> 
>>a) i.e other than the reserved group for controller (which you seem to
>>be taking care of), every other genetlink user has to explicitly
>>register when they need a mcast group. 
> 
> 
> Hm. I'm starting to dislike the dynamic registration the more I think
> about it. Now when a group is unregistered I'd have to unbind everybody
> who's currently using it... At least when I want to enforce
> root/non-root binds which is a further goal.


How about using module references to prevent unloading while sockets
are bound? We already do the same thing for netlink families.
