From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v3] iproute2: add support for GRE ignore-df knob
Date: Thu, 20 Jul 2017 17:26:28 -0700
Message-ID: <20170720172628.06d358b5@xeon-e3>
References: <20170720190610.6886-1-philipp@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michele Lucini <mlucini@safearea.com.au>
To: "Philip Prindeville" <philipp@redfish-solutions.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:38776 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965209AbdGUA0a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 20:26:30 -0400
Received: by mail-pg0-f45.google.com with SMTP id s4so21227830pgr.5
        for <netdev@vger.kernel.org>; Thu, 20 Jul 2017 17:26:30 -0700 (PDT)
In-Reply-To: <20170720190610.6886-1-philipp@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Jul 2017 13:06:10 -0600
"Philip Prindeville" <philipp@redfish-solutions.com> wrote:

> From: Philip Prindeville <philipp@redfish-solutions.com>
> 
> In the presence of firewalls which improperly block ICMP Unreachable
> (including Fragmentation Required) messages, Path MTU Discovery is
> prevented from working.
> 
> The workaround is to handle IPv4 payloads opaquely, ignoring the DF
> bit.
> 
> Kernel commit 22a59be8b7693eb2d0897a9638f5991f2f8e4ddd ("net: ipv4:
> Add ability to have GRE ignore DF bit in IPv4 payloads") is
> complemented by this user-space changeset which exposes control of
> this setting.
> 
> Reviewed-by: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Philip Prindeville <philipp@redfish-solutions.com>

Applied, thanks Philip
