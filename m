From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] bridge: Add fdb dst check during fdb update
Date: Sun, 14 Apr 2013 15:00:47 +0000 (UTC)
Message-ID: <kkegav$4jj$1@ger.gmane.org>
References: <1365915529-8317-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:44496 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751859Ab3DNPBB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Apr 2013 11:01:01 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UROQL-00006y-Oo
	for netdev@vger.kernel.org; Sun, 14 Apr 2013 17:00:58 +0200
Received: from 216-75-227-12.static.wiline.com ([216.75.227.12])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 14 Apr 2013 17:00:57 +0200
Received: from xiyou.wangcong by 216-75-227-12.static.wiline.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 14 Apr 2013 17:00:57 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 14 Apr 2013 at 04:58 GMT, roopa@cumulusnetworks.com <roopa@cumulusnetworks.com> wrote:
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index c581f12..7a7d920 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -615,6 +615,7 @@ static int fdb_add_entry(struct net_bridge_port *source, const __u8 *addr,
>  	struct net_bridge *br = source->br;
>  	struct hlist_head *head = &br->hash[br_mac_hash(addr, vid)];
>  	struct net_bridge_fdb_entry *fdb;
> +	int notify = 0;

Make it 'bool'.
