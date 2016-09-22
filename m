From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH iproute2 net-next] tc: m_vlan: Add vlan modify action
Date: Thu, 22 Sep 2016 20:44:46 +0300
Message-ID: <20160922204446.14a0c23b@halley>
References: <1474536670-2495-1-git-send-email-shmulik.ladkani@gmail.com>
        <20160922090504.3eaa5266@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@resnulli.us>,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:35276 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966233AbcIVRo6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 13:44:58 -0400
Received: by mail-wm0-f46.google.com with SMTP id l132so341461263wmf.0
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 10:44:57 -0700 (PDT)
In-Reply-To: <20160922090504.3eaa5266@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Sep 2016 09:05:04 -0700 Stephen Hemminger <stephen@networkplumber.org> wrote:
> On Thu, 22 Sep 2016 12:31:10 +0300
> Shmulik Ladkani <shmulik.ladkani@ravellosystems.com> wrote:
> 
> > +
> > +static const char *action_name(int action)
> > +{
> > +	static const char * const names[] = {
> > +		[TCA_VLAN_ACT_POP] = "pop",
> > +		[TCA_VLAN_ACT_PUSH] = "push",
> > +		[TCA_VLAN_ACT_MODIFY] = "modify",
> > +	};
> > +	return names[action];
> > +}
> > +  
> 
> Why are you wrapping a simple array lookup in a function?

No reason in particular, was probably code evolution, will amend, thanks.
