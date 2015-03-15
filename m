From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] tc class: Show class names from file
Date: Sun, 15 Mar 2015 12:29:07 -0700
Message-ID: <20150315122907.251a26c4@urahara>
References: <1425400878-7608-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:34590 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751450AbbCOT3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 15:29:06 -0400
Received: by pdbni2 with SMTP id ni2so36981771pdb.1
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 12:29:05 -0700 (PDT)
In-Reply-To: <1425400878-7608-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  3 Mar 2015 18:41:18 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> From: Vadim Kochan <vadim4j@gmail.com>
> 
> It is possible to use class names from file /etc/iproute2/cls_names
> which tc will use when showing class info:
> 
>     # tc/tc -nm class show dev lo
> 	class htb 1:10 parent 1:1 leaf 10: prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
> 	class htb 1:1 root rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
> 	class htb web#1:20 parent 1:1 leaf 20: prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
> 	class htb 1:2 root rate 6Mbit ceil 6Mbit burst 15Kb cburst 1599b
> 	class htb 1:30 parent 1:1 leaf 30: prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
> 	class htb voip#1:40 parent 1:2 leaf 40: prio 0 rate 5Mbit ceil 5Mbit burst 15Kb cburst 1600b
> 	class htb 1:50 parent 1:2 leaf 50: prio 0 rate 3Mbit ceil 6Mbit burst 15Kb cburst 1599b
> 	class htb 1:60 parent 1:2 leaf 60: prio 0 rate 1Kbit ceil 6Mbit burst 15Kb cburst 1599b
> 
> or to specify via file path:
> 
>     # tc/tc -nm -cf /tmp/cls_names class show dev lo
> 
> Class names file contains simple "maj:min  name" structure:
> 
> 1:20    web
> 1:40    voip
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>

Applied, thanks
