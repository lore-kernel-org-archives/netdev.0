From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net v2] lwt: fix rx checksum setting for lwt devices
 tunneling over ipv6
Date: Thu, 18 Feb 2016 10:53:06 +0100
Message-ID: <20160218105306.702ec327@griffin>
References: <244994c83cb73d98205f39aaefcee846dab48260.1455731463.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>, Thomas Graf <tgraf@suug.ch>,
	Pravin Shelar <pshelar@nicira.com>,
	Tom Herbert <tom@herbertland.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36767 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1425825AbcBRJxP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Feb 2016 04:53:15 -0500
In-Reply-To: <244994c83cb73d98205f39aaefcee846dab48260.1455731463.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 17 Feb 2016 19:30:01 +0100, Paolo Abeni wrote:
> the commit 35e2d1152b22 ("tunnels: Allow IPv6 UDP checksums to be
> correctly controlled.") changed the default xmit checksum setting
> for lwt vxlan/geneve ipv6 tunnels, so that now the checksum is not
> set into external UDP header.
> This commit changes the rx checksum setting for both lwt vxlan/geneve
> devices created by openvswitch accordingly, so that lwt over ipv6
> tunnel pairs are again able to communicate with default values.

Acked-by: Jiri Benc <jbenc@redhat.com>
