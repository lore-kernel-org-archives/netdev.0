From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH 2/2] [e1000 VLAN] Disable vlan hw accel
 when promiscuous mode
Date: Mon, 12 Nov 2007 10:01:49 -0800
Message-ID: <4738950D.7070902@intel.com>
References: <47365200.0f10240a.0686.2173@mx.google.com>	<47388988.1000506@intel.com>
	<47388B9F.7050308@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	'Dave Johnson' <djohnson+linux-kernel@sw.starentnetworks.com>,
	linux-kernel@vger.kernel.org, Joonwoo Park <joonwpark81@gmail.com>,
	'David Miller' <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <47388B9F.7050308@trash.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Kok, Auke wrote:
>> Joonwoo Park wrote:
>>> IMHO even though netdevice is in the promiscuous mode, we should receive all of ingress packets.
>>> This disable the vlan filtering feature when a vlan hw accel configured e1000 device goes into promiscuous mode.
>>> This make packets visible to sniffers though it's not vlan id of itself.
>>> Any check, comments will be appreciated.
>> Actually I think this patch removes a choice from the user.
>>
>> Before this patch, the user can sniff all traffic by disabling vlans, or a
>> specific vlan only by leaving vlans on when going into promisc mode.
>>
>> After this patch, the user has no choice but to sniff all vlans at all times.
>>
>> I don't think that that is such a good improvement.
> 
> 
> Do you really consider that a realistic choice? Who is going to
> remove interfaces that are in use just to see traffic for other
> VLANs? Sniffing specific VLANs can always be done on the VLAN
> device itself.

right, I had not thought of that.

> IMO its more a question of what we want promiscous mode to mean,
> and I tend to agree with Joonwoo that it should receive all packets.

OK, Joonwoo: can you submit a patch against e1000e as well?

Auke

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
