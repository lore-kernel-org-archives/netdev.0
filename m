From: Philp Prindeville <philipp@redfish-solutions.com>
Subject: Re: [PATCH v6 1/1] rps: Inspect PPTP encapsulated by GRE to get flow
 hash
Date: Tue, 9 Aug 2016 18:05:13 -0600
Message-ID: <e2c2ac38-4bd2-7f01-35dd-9b4c0310a2c2@redfish-solutions.com>
References: <1470717504-1292-1-git-send-email-fgao@ikuai8.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: gfree.wind@gmail.com
To: fgao@48lvckh6395k16k5.yundunddos.com, davem@davemloft.net,
	stephen@networkplumber.org, pshelar@nicira.com,
	tom@herbertland.com, aduyck@mirantis.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:47898 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752441AbcHJAHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 20:07:18 -0400
In-Reply-To: <1470717504-1292-1-git-send-email-fgao@ikuai8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/08/2016 10:38 PM, fgao@48lvckh6395k16k5.yundunddos.com wrote:
> From: Gao Feng <fgao@ikuai8.com>
>
> The PPTP is encapsulated by GRE header with that GRE_VERSION bits
> must contain one. But current GRE RPS needs the GRE_VERSION must be
> zero. So RPS does not work for PPTP traffic.
>
> In my test environment, there are four MIPS cores, and all traffic
> are passed through by PPTP. As a result, only one core is 100% busy
> while other three cores are very idle. After this patch, the usage
> of four cores are balanced well.
>
> Signed-off-by: Gao Feng <fgao@ikuai8.com>

Reviewed-by: Philip Prindeville <philipp@redfish-solutions.com>
