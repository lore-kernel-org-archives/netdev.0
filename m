From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH RESEND iproute2] ip link set vf: Added "query_rss"
 command
Date: Mon, 4 May 2015 09:08:43 -0700
Message-ID: <20150504090843.33dd82a1@urahara>
References: <1430390803-17959-1-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:35735 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751751AbbEDQIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 12:08:39 -0400
Received: by pdbqd1 with SMTP id qd1so166975453pdb.2
        for <netdev@vger.kernel.org>; Mon, 04 May 2015 09:08:39 -0700 (PDT)
In-Reply-To: <1430390803-17959-1-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 30 Apr 2015 13:46:43 +0300
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

Applied
