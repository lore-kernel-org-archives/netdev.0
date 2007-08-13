From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH 1/4] Net: mac80211, remove bitfields from struct	ieee80211_tx_packet_data
Date: Mon, 13 Aug 2007 21:59:19 +0200
Message-ID: <46C0B817.50707@gmail.com>
References: <32694265142306417777@wsc.cz> <1187009029.27916.107.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	jbenc@suse.cz, flamingice@sourmilk.net, jeff@garzik.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:47660 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031318AbXHMT6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Aug 2007 15:58:34 -0400
Received: by nf-out-0910.google.com with SMTP id g13so571850nfb
        for <netdev@vger.kernel.org>; Mon, 13 Aug 2007 12:58:31 -0700 (PDT)
In-Reply-To: <1187009029.27916.107.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg napsal(a):
> On Sun, 2007-08-12 at 15:08 +0200, Jiri Slaby wrote:
> 
>> +	if (control->flags & IEEE80211_TXCTL_REQ_TX_STATUS)
>> +		pkt_data->flags |= IEEE80211_TXPD_REQ_TX_STATUS;
>> +	if (control->flags & IEEE80211_TXCTL_DO_NOT_ENCRYPT)
>> +		pkt_data->flags |= IEEE80211_TXPD_DO_NOT_ENCRYPT;
>> +	if (control->flags & IEEE80211_TXCTL_REQUEUE)
>> +		pkt_data->flags |= IEEE80211_TXPD_REQUEUE;
>> +	if (control->type == IEEE80211_IF_TYPE_MGMT)
>> +		pkt_data->flags |= IEEE80211_TXPD_MGMT_IFACE;
> 
> This looks weird. Can't we just use the same flags?

I don't think, that it must be subset one of each another in the future. (This
is why I created yet another bits defined).

Do we still want the same flags?

-- 
Jiri Slaby (jirislaby@gmail.com)
Faculty of Informatics, Masaryk University
