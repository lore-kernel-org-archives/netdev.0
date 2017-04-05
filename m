From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH 16/16] drivers, net, intersil: convert request_context.refcount from atomic_t to refcount_t
Date: Wed, 05 Apr 2017 13:33:12 +0300
Message-ID: <87k26zi1p3.fsf@kamboji.qca.qualcomm.com>
References: <1490691403-4016-1-git-send-email-elena.reshetova@intel.com>
        <1490691403-4016-17-git-send-email-elena.reshetova@intel.com>
        <87zifxn2gb.fsf@kamboji.qca.qualcomm.com>
        <2236FBA76BA1254E88B949DDB74E612B41C8741B@IRSMSX102.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-arm-kernel\@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>,
        "linux-rdma\@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-hams\@vger.kernel.org" <linux-hams@vger.kernel.org>,
        "linux-ppp\@vger.kernel.org" <linux-ppp@vger.kernel.org>,
        "linux-wireless\@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "ganeshgr\@chelsio.com" <ganeshgr@chelsio.com>,
        "nbd\@openwrt.org" <nbd@openwrt.org>,
        "blogic\@openwrt.org" <blogic@openwrt.org>,
        "matthias.bgg\@gmail.com" <matthias.bgg@gmail.com>,
        "yishaih\@mellanox.com" <yishaih@mellanox.com>,
        "saeedm\@mellanox.com" <saeedm@mellanox.com>,
        "matanb\@mellanox.com" <matanb@mellanox.com>,
        "leonro\@me
To: "Reshetova\, Elena" <elena.reshetova@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:56244 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933483AbdDEKd0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 06:33:26 -0400
In-Reply-To: <2236FBA76BA1254E88B949DDB74E612B41C8741B@IRSMSX102.ger.corp.intel.com>
        (Elena Reshetova's message of "Tue, 4 Apr 2017 10:07:55 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Reshetova, Elena" <elena.reshetova@intel.com> writes:

>> Elena Reshetova <elena.reshetova@intel.com> writes:
>> 
>> > refcount_t type and corresponding API should be
>> > used instead of atomic_t when the variable is used as
>> > a reference counter. This allows to avoid accidental
>> > refcounter overflows that might lead to use-after-free
>> > situations.
>> >
>> > Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
>> > Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
>> > Signed-off-by: Kees Cook <keescook@chromium.org>
>> > Signed-off-by: David Windsor <dwindsor@gmail.com>
>> > ---
>> >  drivers/net/wireless/intersil/orinoco/orinoco_usb.c | 15 ++++++++-------
>> >  1 file changed, 8 insertions(+), 7 deletions(-)
>> 
>> The prefix should be "orinoco_usb:", I'll fix that.
>
> Thanks for both! Will you take the patches in?

You mean patches 15 and 16? I didn't even look rest of the patches.

But not sure yet because Dave doesn't seem to like the interface and I
want to follow the discussion first.

-- 
Kalle Valo
