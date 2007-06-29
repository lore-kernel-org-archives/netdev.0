From: Patrick McHardy <kaber@trash.net>
Subject: Re: Fwd: [PATCH] [-mm] ACPI: export ACPI events via netlink
Date: Fri, 29 Jun 2007 15:32:12 +0200
Message-ID: <468509DC.6000900@trash.net>
References: <1179827251.7707.29.camel@localhost.localdomain>	 <1179831825.4121.30.camel@localhost>	 <1180258853.7707.53.camel@localhost.localdomain>	 <4466a10705270629h31977813hd2fc8330bcd87f78@mail.gmail.com>	 <4466a10705270634j3560c9a3j9c3630ddc20a24aa@mail.gmail.com>	 <1181811576.5411.27.camel@localhost.localdomain>	 <1181820510.4091.9.camel@localhost>	 <1181869285.5411.39.camel@localhost.localdomain>	 <1182178882.4063.11.camel@localhost>	 <1182223964.5411.76.camel@localhost.localdomain>	 <1182811210.6644.22.camel@johannes.berg>	 <1182986681.5155.55.camel@localhost>	 <1183023939.4769.76.camel@johannes.berg>  <4684F25B.5090607@trash.net>	 <1183121180.4089.51.camel@johannes.berg>  <4684FF9A.10807@trash.net>	 <1183122172.5188.24.camel@localhost>  <46850546.1050606@trash.net> <1183123671.5188.50.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Zhang Rui <rui.zhang@intel.com>, netdev@vger.kernel.org,
	"linux-acpi@vger" <linux-acpi@vger.kernel.org>, lenb@kernel.org,
	Thomas Graf <tgraf@suug.ch>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44857 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762546AbXF2NcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 09:32:25 -0400
In-Reply-To: <1183123671.5188.50.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Fri, 2007-29-06 at 15:12 +0200, Patrick McHardy wrote:
> 
>>jamal wrote:
>>
>>>On Fri, 2007-29-06 at 14:48 +0200, Patrick McHardy wrote:
> 
> 
>>>Our philosophy in genetlink is to have dynamic resources allocated and
>>>released - remember the real reason we even have this is because we were
>>>running out of numbers ;->
>>
>>
>>That was more of a rumour :) We have 2^32-1 groups and I think 256
>>families, of which about 20 are used.
> 
> 
> Well, if thats not the case - we need to fix it ;->


I meant the "running out of numbers" part, we have plenty left.
