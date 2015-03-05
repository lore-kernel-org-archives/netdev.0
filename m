From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] filter: introduce SKF_AD_VLAN_PROTO BPF extension
Date: Thu, 5 Mar 2015 09:52:17 +0100
Message-ID: <20150305085217.GD2033@nanopsycho.orion>
References: <1425501718-12066-1-git-send-email-msekleta@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Alexei Starovoitov <ast@plumgrid.com>,
	Jiri Pirko <jpirko@redhat.com>
To: Michal Sekletar <msekleta@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:46952 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475AbbCEIwW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 03:52:22 -0500
Received: by widem10 with SMTP id em10so36600127wid.5
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 00:52:21 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1425501718-12066-1-git-send-email-msekleta@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Mar 04, 2015 at 09:41:58PM CET, msekleta@redhat.com wrote:
>This commit introduces new BPF extension. It makes possible to load value of
>skb->vlan_proto (vlan tpid) to register A.
>
>Currently, vlan header is removed from frame and information is available to
>userspace only via tpacket interface. Hence, it is not possible to install
>filter which uses value of vlan tpid field.
>
>AFAICT only way how to filter based on tpid value is to reconstruct original
>frame encapsulation and interpret BPF filter code in userspace. Doing that is
>way slower than doing filtering in kernel.
>
>Cc: Alexei Starovoitov <ast@plumgrid.com>
>Cc: Jiri Pirko <jpirko@redhat.com>
>Signed-off-by: Michal Sekletar <msekleta@redhat.com>

Reviewed-by: Jiri Pirko <jiri@resnulli.us>
