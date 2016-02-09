From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH iproute2 v2 21/21] iplink: bridge: add support for
 netfilter call attributes
Date: Tue, 9 Feb 2016 13:00:49 +0100
Message-ID: <20160209120049.GA2377@salvia>
References: <1454973279-9170-1-git-send-email-razor@blackwall.org>
 <1454973279-9170-22-git-send-email-razor@blackwall.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	netfilter-devel@vger.kernel.org, fw@strlen.de
To: Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:38051 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755796AbcBIMA4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Feb 2016 07:00:56 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id D8ADC345
	for <netdev@vger.kernel.org>; Tue,  9 Feb 2016 13:00:54 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id C717DDA814
	for <netdev@vger.kernel.org>; Tue,  9 Feb 2016 13:00:54 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id C6D81DA814
	for <netdev@vger.kernel.org>; Tue,  9 Feb 2016 13:00:52 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <1454973279-9170-22-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Nikolay,

On Tue, Feb 09, 2016 at 12:14:39AM +0100, Nikolay Aleksandrov wrote:
> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> 
> This patch implements support for the IFLA_BR_NF_CALL_(IP|IP6|ARP)TABLES
> attributes in iproute2 so it can change their values.
> 
> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> ---
>  ip/iplink_bridge.c | 45 +++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 45 insertions(+)
> 
> diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
> index a55a36adacdf..1b666f0adef4 100644
> --- a/ip/iplink_bridge.c
> +++ b/ip/iplink_bridge.c
> @@ -47,6 +47,9 @@ static void print_explain(FILE *f)
>  		"                  [ mcast_query_interval QUERY_INTERVAL ]\n"
>  		"                  [ mcast_query_response_interval QUERY_RESPONSE_INTERVAL ]\n"
>  		"                  [ mcast_startup_query_interval STARTUP_QUERY_INTERVAL ]\n"
> +		"                  [ nf_call_iptables NF_CALL_IPTABLES ]\n"
> +		"                  [ nf_call_ip6tables NF_CALL_IP6TABLES ]\n"
> +		"                  [ nf_call_arptables NF_CALL_ARPTABLES ]\n"

We will soon have conntrack support for bridge, that will help us kill
this bridge_netfilter glue code that has caused us many headaches.

So I'd prefer not to give more exposition to this.
