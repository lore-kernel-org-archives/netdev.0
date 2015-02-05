From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/4] ip link: Add support for remote checksum
 offload to IP tunnels
Date: Thu, 5 Feb 2015 10:51:17 -0800
Message-ID: <20150205105117.166df9a8@urahara>
References: <1422550321-30901-1-git-send-email-therbert@google.com>
	<1422550321-30901-2-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:61388 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625AbbBESv2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 13:51:28 -0500
Received: by mail-pa0-f50.google.com with SMTP id rd3so11619742pab.9
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 10:51:28 -0800 (PST)
In-Reply-To: <1422550321-30901-2-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 Jan 2015 08:51:58 -0800
Tom Herbert <therbert@google.com> wrote:

> This patch adds support to remote checksum checksum offload
> confinguration for IPIP, SIT, and GRE tunnels. This patch
> adds a [no]encap-remcsum to ip link command which applicable
> when configured tunnels that use GUE.
> 
> http://tools.ietf.org/html/draft-herbert-remotecsumoffload-00
> 
> Example:
> 
> ip link add name tun1 type gre remote 192.168.1.1 local 192.168.1.2 \
>    ttl 225 encap fou encap-sport auto encap-dport 7777 encap-csum \
>    encap-remcsum
> 
> This would create an GRE tunnel in GUE encapsulation where the source
> port is automatically selected (based on hash of inner packet),
> checksums in the encapsulating UDP header are enabled (needed.for
> remote checksum offload), and remote checksum ffload is configured to
> be used on the tunnel (affects TX side).
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Applied to master since this does not depend on any net-next features.
