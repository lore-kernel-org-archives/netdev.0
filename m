From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net loopback: Set loopback_dev to NULL when
 freed
Date: Mon, 16 Sep 2013 17:50:51 -0700
Message-ID: <1379379051.4751.0.camel@edumazet-glaptop>
References: <1379008796-2121-1-git-send-email-fruggeri@aristanetworks.com>
	 <87txhp249u.fsf@xmission.com>
	 <CA+HUmGgyCsc-er6iB_mqg9whMyaquGWinkHOQEuEHbFCYVrXBw@mail.gmail.com>
	 <871u4t1d9t.fsf@xmission.com>
	 <CA+HUmGjEC8eXT7BHm20uVOagJQbsqO9VZjmGSgmUvnrtEH-JYw@mail.gmail.com>
	 <87d2ocrx9b.fsf@xmission.com>
	 <CA+HUmGifVOs+d=hs2rTUmMyyK17xfBFFbO8sY=rjS2D=RxFLZg@mail.gmail.com>
	 <87six5kpu5.fsf@xmission.com>
	 <CA+HUmGih9akzhpRrb_0WEapi4jGcuSV8qO==QeRWHoqnxzFyng@mail.gmail.com>
	 <87k3iggw8m.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:43334 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751416Ab3IQAux (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 20:50:53 -0400
Received: by mail-pd0-f172.google.com with SMTP id z10so4829282pdj.17
        for <netdev@vger.kernel.org>; Mon, 16 Sep 2013 17:50:53 -0700 (PDT)
In-Reply-To: <87k3iggw8m.fsf_-_@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-09-16 at 16:52 -0700, Eric W. Biederman wrote:
> It has recently turned up that we have a number of long standing bugs
> in the network stack cleanup code with use of the loopback device
> after it has been freed that have not turned up because in most cases
> the storage allocated to the loopback device is not reused, when those
> accesses happen.
> 
> Set looback_dev to NULL to trigger oopses instead of silent data corrupt
> when we hit this class of bug.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>
