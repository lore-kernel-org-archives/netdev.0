From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Fri, 29 Jun 2007 15:53:34 +0200
Message-ID: <46850EDE.5020804@trash.net>
References: <1179827251.7707.29.camel@localhost.localdomain>	 <1179831825.4121.30.camel@localhost>	 <1180258853.7707.53.camel@localhost.localdomain>	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>	 <1181811576.5411.27.camel@localhost.localdomain>	 <1181820510.4091.9.camel@localhost>	 <1181869285.5411.39.camel@localhost.localdomain>	 <1182178882.4063.11.camel@localhost>	 <1182223964.5411.76.camel@localhost.localdomain>	 <1182811210.6644.22.camel@johannes.berg>	 <1182986681.5155.55.camel@localhost>	 <1183121869.4089.57.camel@johannes.berg>  <468504FE.9000502@trash.net>	 <1183122920.4089.63.camel@johannes.berg>  <468507C9.2000800@trash.net>	 <1183124085.4089.66.camel@johannes.berg>  <46850CB8.8000509@trash.net> <1183124981.4089.69.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Zhang Rui <rui.zhang@intel.com>,
	netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1183124981.4089.69.camel@johannes.berg>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> On Fri, 2007-06-29 at 15:44 +0200, Patrick McHardy wrote:
> 
> 
>>>How about for now I only allow dynamic registration (no unregistration)
>>>and just send out when new groups are registered, and also give
>>>userspace a list of registered mc groups when they ask for a family
>>>description? That should make this patch not too big and still leaves
>>>room for dynamic unregistration later.
>>
>>
>>How does it deal with unregistration currently? If it leaves sockets
>>subscribed that seems like a bug already, at least if the id was
>>dynamically generated. Of course it would require the id to be
>>reused to actually matter.
> 
> 
> Hmm. I don't see it kicking out the socket subscriptions in
> genl_unregister_family so I guess that bug is present.


If you're worried about patch size, you could sell that part as a
bugfix :)

