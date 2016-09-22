From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 net-next] tc: m_vlan: Add vlan modify action
Date: Thu, 22 Sep 2016 09:05:04 -0700
Message-ID: <20160922090504.3eaa5266@xeon-e3>
References: <1474536670-2495-1-git-send-email-shmulik.ladkani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:35603 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754609AbcIVQEz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 12:04:55 -0400
Received: by mail-pf0-f176.google.com with SMTP id z123so32047137pfz.2
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 09:04:54 -0700 (PDT)
In-Reply-To: <1474536670-2495-1-git-send-email-shmulik.ladkani@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Sep 2016 12:31:10 +0300
Shmulik Ladkani <shmulik.ladkani@ravellosystems.com> wrote:

> +
> +static const char *action_name(int action)
> +{
> +	static const char * const names[] = {
> +		[TCA_VLAN_ACT_POP] = "pop",
> +		[TCA_VLAN_ACT_PUSH] = "push",
> +		[TCA_VLAN_ACT_MODIFY] = "modify",
> +	};
> +	return names[action];
> +}
> +

Why are you wrapping a simple array lookup in a function?
