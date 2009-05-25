From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH] ieee1394: eth1394: use "firewire%d" instead of "eth%d"
 as interface name
Date: Mon, 25 May 2009 12:43:37 +0200
Message-ID: <4A1A7659.6060201@s5r6.in-berlin.de>
References: <tkrat.21c425cc195510c9@s5r6.in-berlin.de> <alpine.DEB.2.01.0905232309400.7424@bogon> <tkrat.6c3758bf0544a790@s5r6.in-berlin.de> <200905251033.09272.zzam@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-hotplug@vger.kernel.org,
	Christian Kujau <lists@nerdbynature.de>,
	linux-kernel@vger.kernel.org,
	linux1394-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Matthias Schwarzott <zzam@gentoo.org>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <200905251033.09272.zzam@gentoo.org>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matthias Schwarzott wrote:
> On Sonntag, 24. Mai 2009, Stefan Richter wrote:
>> Besides, if we can we should avoid fw%d because this will clash with
>> udev rules which match KERNEL=="fw*", as in
>> udev/rules/redhat/40-redhat.rules.
> 
> I suggest a subsystem match here, or generally some
> SUBSYSTEM!="net", GOTO="end_of_file"
> around almost all rule files that should not match on network interfaces, as 
> users can rename them to almost all crazy names.
> 
> @Kay: Perhaps it could simplify some rulesets to have a special jump target or 
> option to skip entiere rules files.

Right...  Luckily, 75-persistent-net-generator.rules already has a big
SUBSYSTEM!="net", GOTO="persistent_net_generator_end" around everything.

Also, "fw*" devices related rules which I'll submit RSN will have
SUBSYSTEM=="firewire" prefixes.
-- 
Stefan Richter
-=====-==--= -=-= ==--=
http://arcgraph.de/sr/
