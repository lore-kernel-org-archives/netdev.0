From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 2/2] geneve: handle ipv6 priority like ipv4 tos
Date: Wed, 21 Oct 2015 13:13:39 +0800
Message-ID: <CAEP_g=91tQh6x4FWe5euddtS-Apv1Wm2Z4YupF7cGMnoV3bpVg@mail.gmail.com>
References: <1443638045-27229-1-git-send-email-linville@tuxdriver.com>
 <1445353866-32710-1-git-send-email-linville@tuxdriver.com> <1445353866-32710-2-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, Dave Miller <davem@davemloft.net>,
	Pravin B Shelar <pshelar@nicira.com>,
	Jiri Benc <jbenc@redhat.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f47.google.com ([209.85.215.47]:36823 "EHLO
	mail-lf0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076AbbJUFOB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 01:14:01 -0400
Received: by lffz202 with SMTP id z202so15583381lff.3
        for <netdev@vger.kernel.org>; Tue, 20 Oct 2015 22:13:59 -0700 (PDT)
In-Reply-To: <1445353866-32710-2-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 20, 2015 at 11:11 PM, John W. Linville
<linville@tuxdriver.com> wrote:
> Other callers of udp_tunnel6_xmit_skb just pass 0 for the prio
> argument.  Jesse Gross <jesse@nicira.com> suggested that prio is really
> the same as IPv4's tos and should be handled the same, so this is my
> interpretation of that suggestion.
>
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> Reported-by: Jesse Gross <jesse@nicira.com>

Reviewed-by: Jesse Gross <jesse@nicira.com>
