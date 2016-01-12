From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2] net: bpf: reject invalid shifts
Date: Tue, 12 Jan 2016 14:34:48 -0800
Message-ID: <1452638088.1223.28.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160112185121.GA34045@ast-mbp.thefacebook.com>
	 <1452626228-15742-1-git-send-email-rabin@rab.in>
	 <1452628118.1223.25.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160112195356.GA34598@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rabin Vincent <rabin@rab.in>, davem@davemloft.net,
	netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net,
	linux-arm-kernel@lists.infradead.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36515 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753202AbcALWeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jan 2016 17:34:50 -0500
Received: by mail-pa0-f52.google.com with SMTP id yy13so254018383pab.3
        for <netdev@vger.kernel.org>; Tue, 12 Jan 2016 14:34:49 -0800 (PST)
In-Reply-To: <20160112195356.GA34598@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-01-12 at 11:53 -0800, Alexei Starovoitov wrote:
> On Tue, Jan 12, 2016 at 11:48:38AM -0800, Eric Dumazet wrote:

> > 
> > I believe we should add a one time warning to give a clue to poor users
> > hitting this problem.
> 
> you mean like warn_on_once() here?
> Makes sense I guess.


pr_err(DEPRECATED, "%s (pid %d) "
                   "invalid shift in BPF program.\n"
                   current->comm, task_pid_nr(current));

Or something like that.
