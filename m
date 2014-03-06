From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: brcmfmac: fix skb leak in brcmf_sdio_txpkt_prep_sg error path.
Date: Fri, 07 Mar 2014 00:41:50 +0300
Message-ID: <5318EB9E.808@cogentembedded.com>
References: <20140305192636.D06AA660D72@gitolite.kernel.org> <20140306060936.GB26578@redhat.com> <53183722.7000301@broadcom.com> <20140306170354.GA31372@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com,
	linux-coverity@vger.kernel.org
To: Dave Jones <davej@redhat.com>,
	Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:43799 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751548AbaCFUlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 15:41:45 -0500
Received: by mail-la0-f53.google.com with SMTP id b8so2182056lan.12
        for <netdev@vger.kernel.org>; Thu, 06 Mar 2014 12:41:43 -0800 (PST)
In-Reply-To: <20140306170354.GA31372@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 03/06/2014 08:03 PM, Dave Jones wrote:

> Commit 1eb4301867 added an allocation of an skb via brcmu_pkt_buf_get_skb()

    Please also specify that commit's summary line is parens.

> but forgot to free it on one of the error paths.

> Cc: Arend van Spriel <arend@broadcom.com>
> Signed-off-by: Dave Jones <davej@fedoraproject.org>

WBR, Sergei
