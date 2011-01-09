From: Jesse Gross <jesse@nicira.com>
Subject: Re: [PATCH 2/2] sky2: convert to new VLAN model (v0.2)
Date: Sun, 9 Jan 2011 11:13:31 -0500
Message-ID: <AANLkTimyfSJwgcDOQK2hpWdJ08CNCerLM=0+NBA6+VZd@mail.gmail.com>
References: <20110106204146.16b3a328@nehalam>
	<AANLkTikwGQFByOZGgCCjTJySPa8QYndZ903CFmOkS1Ha@mail.gmail.com>
	<20110107201350.0be350bf@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:62755 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752147Ab1AIQNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Jan 2011 11:13:32 -0500
Received: by ywl5 with SMTP id 5so7268295ywl.19
        for <netdev@vger.kernel.org>; Sun, 09 Jan 2011 08:13:31 -0800 (PST)
In-Reply-To: <20110107201350.0be350bf@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 7, 2011 at 11:13 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> This converts sky2 to new VLAN offload flags control via ethtool.
> It also allows for transmit offload of vlan tagged frames which
> was not possible before.
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
> ---
> Changed the setting of vlan_features in this version to keep
> non-offload settings (GRO|HIGHDMA) even if vlan offload is not
> enabled.

Thanks Stephen.

Reviewed-by: Jesse Gross <jesse@nicira.com>
