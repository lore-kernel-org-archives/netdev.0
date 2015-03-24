From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip link set vf: Added "query_rss" command
Date: Tue, 24 Mar 2015 15:47:32 -0700
Message-ID: <20150324154732.57d84cb6@urahara>
References: <1427050378-15004-1-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:36679 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751842AbbCXWr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 18:47:29 -0400
Received: by pdbcz9 with SMTP id cz9so7488981pdb.3
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 15:47:28 -0700 (PDT)
In-Reply-To: <1427050378-15004-1-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 22 Mar 2015 20:52:58 +0200
Vlad Zolotarov <vladz@cloudius-systems.com> wrote:

> Add a new option to toggle the ability of querying the RSS configuration of a specific VF.
> 
> VF RSS information like RSS hash key may be considered sensitive on some devices where
> this information is shared between VF and PF and thus its querying may be prohibited by default.
> 
> This new option allows a system administrator with privileges to modify a PF state
> to control if the above VF querying is allowed or not.
> 
> For example:
>  To enable RSS querying of VF[0] of ethX:
>  >> ip link set dev ethX vf 0 query_rss on  
> 
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>

Holding off on this going into iproute until kernel component goes
into net-next
