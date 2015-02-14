From: Joe Stringer <joestringer@nicira.com>
Subject: Re: [RFC net-next 3/4] openvswitch: Add conntrack action.
Date: Sat, 14 Feb 2015 00:20:12 -0800
Message-ID: <CANr6G5ywfBVAwhi2=h+rV5iS6THOO0+GsH4J68FHRmMogyx2Pg@mail.gmail.com>
References: <1423901633-53789-1-git-send-email-joestringer@nicira.com> <1423901633-53789-4-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Justin Pettit <jpettit@nicira.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Thomas Graf <tgraf@suug.ch>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:47176 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752633AbbBNIUe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2015 03:20:34 -0500
Received: by mail-wi0-f181.google.com with SMTP id r20so16841871wiv.2
        for <netdev@vger.kernel.org>; Sat, 14 Feb 2015 00:20:32 -0800 (PST)
In-Reply-To: <1423901633-53789-4-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14 February 2015 at 00:13, Joe Stringer <joestringer@nicira.com> wrote:
> From: Justin Pettit <jpettit@nicira.com>
>
> Expose the kernel connection tracker to OVS. Userspace components can
> make use of the "conntrack()" action, followed by "recirculate", to
> populate the conntracking state in the OVS flow key, and subsequently
> match on that state.
>
> IP fragment handling is yet to be addressed, for the time being we pass
> fragments through to conntrack directly, which I expect will result in
> the connection being identified as "invalid".
>
> Zone support added by Thomas Graf <tgraf@noironetworks.com>
>
> Signed-off-by: Justin Pettit <jpettit@nicira.com>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
> This is mostly a tidyup and port across to net-next from the previous
> version of this patch. Newly added is ability to match on zones, adding
> support for matching connections that cannot be identified ("invalid"),
> and more testing in the userspace component which is available here:
>
> https://www.github.com/justinpettit/openvswitch conntrack

That is,  https://www.github.com/justinpettit/ovs conntrack
