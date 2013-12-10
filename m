From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next] net: ovs: use kfree_rcu instead of rcu_free_{sw_flow_mask_cb,acts_callback}
Date: Tue, 10 Dec 2013 13:18:40 -0800
Message-ID: <CAEP_g=_97j4e9u=WgUHQuHZw9N14ooRKQfiKfPCi14C9zf0eXg@mail.gmail.com>
References: <1386673323-17101-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:37806 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751046Ab3LJVTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 16:19:01 -0500
Received: by mail-ie0-f181.google.com with SMTP id e14so9101301iej.26
        for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 13:19:00 -0800 (PST)
In-Reply-To: <1386673323-17101-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 10, 2013 at 3:02 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> As we're only doing a kfree() anyway in the RCU callback, we can
> simply use kfree_rcu, which does the same job, and remove the
> function rcu_free_sw_flow_mask_cb() and rcu_free_acts_callback().
>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied, thanks.
