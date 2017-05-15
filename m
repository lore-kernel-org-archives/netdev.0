From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 master 0/4] pedit: Introduce IPv6 support +
 some minor fixes
Date: Mon, 15 May 2017 15:06:37 -0700
Message-ID: <20170515150637.1856cbbe@xeon-e3>
References: <20170514081746.9010-1-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:34394 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751068AbdEOWGk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 18:06:40 -0400
Received: by mail-pf0-f179.google.com with SMTP id 9so29786479pfj.1
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 15:06:40 -0700 (PDT)
In-Reply-To: <20170514081746.9010-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 14 May 2017 11:17:42 +0300
Amir Vadai <amir@vadai.me> wrote:

> Hi,
> 
> This patchset introduces pedit IPv6 support.
> Almost all IPv6 header fields are editable now (src, dst, flow_lbl,
> payload_len, next_hdr and hoplimit).
> The patch uses the new extended pedit netlink and will fail the operation if
> kernel has no support or user didn't use the 'ex' keyword.
> In addition to this patch, 3 more patches fix some minor UI issues:
> - some typo's
> - 'retain' can't be used with fields > 32 bits. It will make unexpected things
> 	when used in such fields. Fixing this limitiation requires some changes (in
> 	tc user space only) that are out of the scope of this patchset. So I added a
> 	patch to prevent the user from using retain on those fields.
> 
> 
> Thanks,
> Amir	
> 
> Amir Vadai (4):
>   pedit: Fix a typo in warning
>   pedit: Do not allow using retain for too big fields
>   pedit: Check for extended capability in protocol parser
>   pedit: Introduce ipv6 support
> 
>  man/man8/tc-pedit.8 | 33 ++++++++++++++++++-
>  tc/Makefile         |  1 +
>  tc/m_pedit.c        | 51 ++++++++++++++++++++++++++++--
>  tc/p_eth.c          |  3 ++
>  tc/p_ip.c           | 17 +---------
>  tc/p_ip6.c          | 91 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  tc/p_udp.c          |  3 ++
>  7 files changed, 179 insertions(+), 20 deletions(-)
>  create mode 100644 tc/p_ip6.c
> 

Looks good. Applied.
