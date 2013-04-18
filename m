From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 2/2] openvswitch: Use lockless genl.
Date: Thu, 18 Apr 2013 11:31:44 -0700
Message-ID: <CAEP_g=_17-e-up39hV9GFsLtYdeVLHqLKCkAc44bzGTaOt5jUA@mail.gmail.com>
References: <1366303924-30701-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog129.obsmtp.com ([74.125.149.142]:43361 "HELO
	na3sys009aog129.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751419Ab3DRScH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 14:32:07 -0400
Received: by mail-ia0-f198.google.com with SMTP id p22so6723506iad.9
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 11:32:05 -0700 (PDT)
In-Reply-To: <1366303924-30701-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 18, 2013 at 9:52 AM, Pravin B Shelar <pshelar@nicira.com> wrote:
> Following patch uses of lockless genl callbacks for ovs.
>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

I think this is clearly the right thing to do (assuming that the genl
part passes review from other people). However, can you expand the
commit message for this patch a little bit to describe why it is safe
and some of the benefits?
