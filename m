From: Guy Harris <guy@alum.mit.edu>
Subject: Re: [PATCH] filter: introduce SKF_AD_VLAN_PROTO BPF extension
Date: Wed, 4 Mar 2015 13:14:39 -0800
Message-ID: <6E5AAA23-4000-4C29-BB4E-AA7C05B6F619@alum.mit.edu>
References: <1425501718-12066-1-git-send-email-msekleta@redhat.com> <54F77336.7040006@plumgrid.com>
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Michal Sekletar <msekleta@redhat.com>, netdev@vger.kernel.org,
	Jiri Pirko <jpirko@redhat.com>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from d.mail.sonic.net ([64.142.111.50]:57824 "EHLO d.mail.sonic.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752461AbbCDVOn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Mar 2015 16:14:43 -0500
In-Reply-To: <54F77336.7040006@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mar 4, 2015, at 1:03 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:

> the patch is correct and looks clean, but I don't understand
> the motivation for the patch.
> There is already SKF_AD_VLAN_TAG_PRESENT. If it is set then only
> two possible values of vlan_proto are ETH_P_8021Q or ETH_P_8021AD.
> If there another vlan header inside the packet, it's AD.
> So you can do the filtering already without adding new bpf extension...

I presume he's referring to

	https://github.com/the-tcpdump-group/libpcap/issues/397

or

	https://github.com/the-tcpdump-group/libpcap/issues/390
