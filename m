From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH nf-next v8 3/8] openvswitch: Add commentary to conntrack.c
Date: Wed, 9 Mar 2016 16:50:13 +0300
Message-ID: <56E02A15.6030005@cogentembedded.com>
References: <1457483084-13944-1-git-send-email-jarno@ovn.org>
 <1457483084-13944-3-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: Jarno Rajahalme <jarno@ovn.org>, netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:33887 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932519AbcCINu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 08:50:27 -0500
Received: by mail-lb0-f172.google.com with SMTP id xr8so64192024lbb.1
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 05:50:27 -0800 (PST)
In-Reply-To: <1457483084-13944-3-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/9/2016 3:24 AM, Jarno Rajahalme wrote:

> This makes the code easier to understand and the following patches
> more focused.
>
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
> ---
>   net/openvswitch/conntrack.c | 21 ++++++++++++++++++++-
>   1 file changed, 20 insertions(+), 1 deletion(-)
>
> diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
> index 3045290..8cd0110 100644
> --- a/net/openvswitch/conntrack.c
> +++ b/net/openvswitch/conntrack.c
[...]
> @@ -418,6 +429,13 @@ static int ovs_ct_lookup(struct net *net, struct sw_flow_key *key,
>   {
>   	struct nf_conntrack_expect *exp;
>
> +	/* If we pass an expected packet through nf_conntrack_in() the
> +	 * expectiation is typically removed, but the packet could still be

    Expectation.
[...]

MBR, Sergei
