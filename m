From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 1/1] iroute2: Add support for GRE ignore-df knob
Date: Thu, 20 Jul 2017 08:42:35 -0700
Message-ID: <20170720084235.691873e0@xeon-e3>
References: <20170720051933.5051-1-philipp@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michele Lucini <mlucini@safearea.com.au>
To: "Philip Prindeville" <philipp@redfish-solutions.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:35929 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934678AbdGTPmi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 11:42:38 -0400
Received: by mail-pf0-f178.google.com with SMTP id o88so13638493pfk.3
        for <netdev@vger.kernel.org>; Thu, 20 Jul 2017 08:42:38 -0700 (PDT)
In-Reply-To: <20170720051933.5051-1-philipp@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 19 Jul 2017 23:19:33 -0600
"Philip Prindeville" <philipp@redfish-solutions.com> wrote:

> From: Philip Prindeville <philipp@redfish-solutions.com>
> 
> In the presence of firewalls which improperly block ICMP Unreachable
> (including Fragmentation Required) messages, Path MTU Discovery is
> prevented from working.
> 
> The workaround is to handle IPv4 payloads opaquely, ignoring the DF bit.
> 
> Reviewed-by: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Philip Prindeville <philipp@redfish-solutions.com>
> ---
>  doc/ip-cref.tex      |  7 +++++++
>  ip/link_gre.c        | 16 ++++++++++++++++
>  man/man8/ip-tunnel.8 |  9 +++++++++
>  3 files changed, 32 insertions(+)
> 

Please fix Subject line and the following minor checkpatch warnings and resubmit


WARNING: line over 80 characters
#109: FILE: ip/link_gre.c:170:
+			ignore_df = !!rta_getattr_u8(greinfo[IFLA_GRE_IGNORE_DF]);

WARNING: Block comments use a trailing */ on a separate line
#121: FILE: ip/link_gre.c:322:
+			// only the lsb is significant, use 2 for presence */

total: 0 errors, 2 warnings, 86 lines checked
