From: Fabio Estevam <festevam@gmail.com>
Subject: Re: net/ipv4/fib_trie.c:1550 suspicious rcu_dereference_check() usage
Date: Tue, 10 Mar 2015 13:20:10 -0300
Message-ID: <CAOMZO5C4Tg12r7W7msm_KPEhV1QxR1Uij-f_UBtVRUeTFxzn_w@mail.gmail.com>
References: <CAOMZO5Aghpf7b-p0YWB_PdF-frN-rERmdjoUOk+PW_rzJY+eMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Olof Johansson <olof@lixom.net>
To: "David S. Miller" <davem@davemloft.net>,
	alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:40188 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932137AbbCJQUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 12:20:12 -0400
Received: by lbiw7 with SMTP id w7so2903762lbi.7
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 09:20:10 -0700 (PDT)
In-Reply-To: <CAOMZO5Aghpf7b-p0YWB_PdF-frN-rERmdjoUOk+PW_rzJY+eMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 10, 2015 at 1:19 AM, Fabio Estevam <festevam@gmail.com> wrote:
> Hi,
>
> On a imx6sl-warp board running linux-next 20150306:
>
> root@imx6sl-warp:~# reboot
>
> The system is going down for reboot NOW!(ttymxc0) (Wed Feb 25 18:41:59 2015):
> INIT: Switching to runlevel: 6
> INIT: Sending processes the TERM signal
> INIT: Sending processe Stopping syslogd/klogd: stopped syslogd (pid 301)
> stopped klogd (pid 304)
> done
> Deconfiguring network interfaces... [   36.083246]
> [   36.084753] ===============================
> [   36.089026] [ INFO: suspicious RCU usage. ]
> [   36.093217] 4.0.0-rc2-next-20150306-00003-g62c7037-dirty #2699 Not tainted

It seems that the issue is gone in linux-next 20150310.
