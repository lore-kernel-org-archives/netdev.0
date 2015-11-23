From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH 00/12] smaller iptunnel and ip6tunnel review
Date: Mon, 23 Nov 2015 15:28:57 -0800
Message-ID: <20151123152857.3d733d97@xeon-e3>
References: <1447434545-32182-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:59177 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751812AbbKXABK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 19:01:10 -0500
In-Reply-To: <1447434545-32182-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Nov 2015 18:08:53 +0100
Phil Sutter <phil@nwl.cc> wrote:

> In an effort to try and merge iptunnel and ip6tunnel support code, I found a
> few things worth changing, mainly by comparing the two files.
> 
> Please note that I did not test functionality of all supported tunnel modes,
> but since the changes are fairly small and obvious I hopefully didn't introduce
> too many bugs.
> 
> Phil Sutter (12):
>   ip{,6}tunnel: get rid of extraneous whitespace when printing
>   ip/tunnel: introduce tnl_parse_key()
>   ip{,6}tunnel: unify behaviour if physical device is not found
>   iptunnel: use ll_name_to_index() for physical interface lookup
>   ip{,6}tunnel: align do_tunnels_list() a bit
>   ip6tunnel: print local/remote addresses like iptunnel does
>   ip6tunnel: fix coding style: no newline between brace and else
>   iptunnel: share common code when setting tunnel mode
>   iptunnel: simplify parsing TTL, allow 'hlim' as identifier
>   iptunnel: share common code when determining the default interface
>     name
>   iptunnel: sanitize copying tunnel name
>   ip{,6}tunnel: put spaces around non-unary operators
> 
>  ip/ip6tunnel.c |  83 +++++++-------------
>  ip/iptunnel.c  | 239 ++++++++++++++++++++++-----------------------------------
>  ip/tunnel.c    |  15 ++++
>  ip/tunnel.h    |   1 +
>  4 files changed, 135 insertions(+), 203 deletions(-)
> 

Sure these all make sense. Applied
