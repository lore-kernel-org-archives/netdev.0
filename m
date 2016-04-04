From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v5 net-next] net: ipv4: Consider failed nexthops in
 multipath routes
Date: Mon, 4 Apr 2016 07:29:54 -0600
Message-ID: <57026C52.1070905@cumulusnetworks.com>
References: <1459728547-36371-1-git-send-email-dsa@cumulusnetworks.com>
 <alpine.LFD.2.11.1604040917390.2182@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:35259 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495AbcDDN37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2016 09:29:59 -0400
Received: by mail-ig0-f171.google.com with SMTP id gy3so18164095igb.0
        for <netdev@vger.kernel.org>; Mon, 04 Apr 2016 06:29:58 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.11.1604040917390.2182@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/4/16 12:29 AM, Julian Anastasov wrote:
> Reviewed-by: Julian Anastasov <ja@ssi.bg>
>
> 	With one comment: the fallback strategy is simplified,
> we do not fallback to all possible reachable nexthops.
>

Right. I will send a second patch that examines other nexthops (hash <= 
nh_upper_bound).
