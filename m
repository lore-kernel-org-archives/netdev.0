From: Ben Greear <greearb@candelatech.com>
Subject: Re: Question on TSO maximum segment sizes.
Date: Thu, 11 Oct 2007 17:17:48 -0700
Message-ID: <470EBD2C.8020704@candelatech.com>
References: <D5C1322C3E673F459512FB59E0DDC32903C4407B@orsmsx414.amr.corp.intel.com><20071011.163737.36654032.davem@davemloft.net><470EB6D6.9020704@hp.com> <20071011.170244.32082446.davem@davemloft.net> <D5C1322C3E673F459512FB59E0DDC32903C440EE@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:35864 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753292AbXJLAR5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2007 20:17:57 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32903C440EE@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
>> From: Rick Jones <rick.jones2@hp.com>
>> Date: Thu, 11 Oct 2007 16:50:46 -0700
>>
>>> For just messing about, might it be possible to tweak the socket 
>>> buffer sizes and tcp_tso_win_divisor to kludge things for a short 
>>> while?  Couldn't ship that way certainly, but assuming 
>> Peter's going 
>>> to get his broken hardware fixed it might let him limp 
>> along until then.
>>
>> TCP dynamically grows the socket buffer sizes unless the 
>> application explicitly sets them via setsockopt() and the 
>> limits imposed in those cases are controlled by 
>> tcp_{,r,w}mem[] sysctls.  Decreasing those will kill 
>> performance exactly for the cases this person cares about.

I just tried turning off my explicit SO_SNDBUF/SO_RCVBUG settings in my app,
and the connection ran very poorly through a link with even a small
bit of latency (~2-4ms I believe).

It ran near gige line speed through a cross-over cable.

I have the sysctl max values set very generous, though the min
and default are fairly small.

This was with kernel 2.6.20.

Was the auto-tuning put in after 2.6.20?  If not, has this
been tested through a higher latency link?  Or, am I confused
and you are talking about some other setsockopt?

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

