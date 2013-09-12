From: Francesco Ruggeri <fruggeri@aristanetworks.com>
Subject: Re: [PATCH 1/1] net: race condition when removing virtual net_device
Date: Thu, 12 Sep 2013 15:02:22 -0700
Message-ID: <CA+HUmGjDKKke7PXr3Bps1oVx7X9JN5-2+uUhxKDkqoT8nbPLWw@mail.gmail.com>
References: <1379008796-2121-1-git-send-email-fruggeri@aristanetworks.com>
	<87txhp249u.fsf@xmission.com>
	<CA+HUmGgyCsc-er6iB_mqg9whMyaquGWinkHOQEuEHbFCYVrXBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Cong Wang <amwang@redhat.com>, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f170.google.com ([209.85.220.170]:46885 "EHLO
	mail-vc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754562Ab3ILWCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Sep 2013 18:02:22 -0400
Received: by mail-vc0-f170.google.com with SMTP id kw10so342515vcb.15
        for <netdev@vger.kernel.org>; Thu, 12 Sep 2013 15:02:22 -0700 (PDT)
In-Reply-To: <CA+HUmGgyCsc-er6iB_mqg9whMyaquGWinkHOQEuEHbFCYVrXBw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 12, 2013 at 2:48 PM, Francesco Ruggeri
<fruggeri@aristanetworks.com> wrote:
> On Thu, Sep 12, 2013 at 1:06 PM, Eric W. Biederman
> <ebiederm@xmission.com> wrote:
>> Francesco Ruggeri <fruggeri@aristanetworks.com> writes:
...
> netdev_run_todo. This guarantees that no deadlocks are introduced,
> since the relative order of net_devices within each namespace is
> preserved, and only non-loopback_devs take and release the extra
> reference.

I should have said "since in net_todo_list the relative order of
net_devices within each namespace is the same as before, ...".

Sorry for any confusion.

Francesco
