From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next v2 2/2] openvswitch: Use lockless genl.
Date: Thu, 18 Apr 2013 17:25:31 -0700
Message-ID: <CAEP_g=9=yVdYfE2oT5ngTuE9xKD8VBMqoB1cctyg+m6=snb5gg@mail.gmail.com>
References: <1366320653-16941-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog133.obsmtp.com ([74.125.149.82]:40144 "HELO
	na3sys009aog133.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S967537Ab3DSAZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 20:25:52 -0400
Received: by mail-ob0-f198.google.com with SMTP id ta14so18274544obb.9
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 17:25:51 -0700 (PDT)
In-Reply-To: <1366320653-16941-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 18, 2013 at 2:30 PM, Pravin B Shelar <pshelar@nicira.com> wrote:
> OVS locking was recently changed to have private OVS lock which
> simplified overall locking.  Therefore there is no need to have
> another global genl lock to protect OVS data structures.  Following
> patch uses of lockless genl family for OVS.  This also allows
> more granual OVS locking using ovs_mutex for protecting OVS data
> structures, which gives more concurrencey.  E.g multiple genl
> operations OVS_PACKET_CMD_EXECUTE can run in parallel, etc.
>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
> Updated commit msg according comment From Jesse.

Once the genl parts have been reviewed:
Acked-by: Jesse Gross <jesse@nicira.com>
