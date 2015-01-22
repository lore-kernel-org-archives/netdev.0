From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH net-next v14 5/5] openvswitch: Add support for unique flow IDs.
Date: Wed, 21 Jan 2015 17:16:36 -0800
Message-ID: <CALnjE+ovJvdnW+PQFKqs4aRMApO=o=th6CGjM_DJdNLWrUVJPg@mail.gmail.com>
References: <1421887372-56414-1-git-send-email-joestringer@nicira.com>
	<1421887372-56414-6-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:55479 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753582AbbAVBQg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 20:16:36 -0500
Received: by mail-ie0-f169.google.com with SMTP id rl12so21061237iec.0
        for <netdev@vger.kernel.org>; Wed, 21 Jan 2015 17:16:36 -0800 (PST)
In-Reply-To: <1421887372-56414-6-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 21, 2015 at 4:42 PM, Joe Stringer <joestringer@nicira.com> wrote:
> Previously, flows were manipulated by userspace specifying a full,
> unmasked flow key. This adds significant burden onto flow
> serialization/deserialization, particularly when dumping flows.
>
> This patch adds an alternative way to refer to flows using a
> variable-length "unique flow identifier" (UFID). At flow setup time,
> userspace may specify a UFID for a flow, which is stored with the flow
> and inserted into a separate table for lookup, in addition to the
> standard flow table. Flows created using a UFID must be fetched or
> deleted using the UFID.
>
> All flow dump operations may now be made more terse with OVS_UFID_F_*
> flags. For example, the OVS_UFID_F_OMIT_KEY flag allows responses to
> omit the flow key from a datapath operation if the flow has a
> corresponding UFID. This significantly reduces the time spent assembling
> and transacting netlink messages. With all OVS_UFID_F_OMIT_* flags
> enabled, the datapath only returns the UFID and statistics for each flow
> during flow dump, increasing ovs-vswitchd revalidator performance by 40%
> or more.
>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>

Looks good.
Acked-by: Pravin B Shelar <pshelar@nicira.com>

Thanks.
