From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net] openvswitch: Consistently include VLAN header in flow
 and port stats.
Date: Wed, 31 Dec 2014 13:12:28 -0800
Message-ID: <CALnjE+rT84cERDkJK_A3yF5fvmd=NxwR02BfGyYVxyvbMu67yA@mail.gmail.com>
References: <1420044346-27957-1-git-send-email-blp@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Motonori Shindo <mshindo@vmware.com>
To: Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog102.obsmtp.com ([74.125.149.69]:55444 "HELO
	na3sys009aog102.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751790AbaLaVM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 16:12:29 -0500
Received: by mail-ie0-f181.google.com with SMTP id rl12so13526751iec.40
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 13:12:28 -0800 (PST)
In-Reply-To: <1420044346-27957-1-git-send-email-blp@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 31, 2014 at 8:45 AM, Ben Pfaff <blp@nicira.com> wrote:
> Until now, when VLAN acceleration was in use, the bytes of the VLAN header
> were not included in port or flow byte counters.  They were however
> included when VLAN acceleration was not used.  This commit corrects the
> inconsistency, by always including the VLAN header in byte counters.
>
> Previous discussion at
> http://openvswitch.org/pipermail/dev/2014-December/049521.html
>
> Reported-by: Motonori Shindo <mshindo@vmware.com>
> Signed-off-by: Ben Pfaff <blp@nicira.com>

Looks good.

Acked-by: Pravin B Shelar <pshelar@nicira.com>
