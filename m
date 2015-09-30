From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH net-next 2/2] openvswitch: netlink attributes for IPv6 tunneling
Date: Tue, 29 Sep 2015 20:05:00 -0700
Message-ID: <CAEP_g=-oijtUY1fD7AqK5PndCAt85uEF1Gh0yqbqz0u3-bPcRg@mail.gmail.com>
References: <cover.1443548447.git.jbenc@redhat.com> <ac7ce77d8104dca2c8378096575276984dd2a11e.1443548447.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Pravin Shelar <pshelar@nicira.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:36131 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752854AbbI3DFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 23:05:21 -0400
Received: by laclj5 with SMTP id lj5so30365652lac.3
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 20:05:20 -0700 (PDT)
In-Reply-To: <ac7ce77d8104dca2c8378096575276984dd2a11e.1443548447.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 29, 2015 at 10:52 AM, Jiri Benc <jbenc@redhat.com> wrote:
> When compat code for tunnel configuration is used, IPv6 tun_info will be
> rejected by ovs_tunnel_get_egress_info. As the consequence, only the new way
> of tunnel config supports IPv6.

This appears to me to be a bug in the existing code.
ovs_tunnel_get_egress_info() as a general mechanism is still in use
and should work with both the old and new configuration methods.
However, I agree that it doesn't look like it will work currently with
tunnel devices. I think we need to fix this rather than making it more
broken.
