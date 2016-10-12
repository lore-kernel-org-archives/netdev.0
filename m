From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v3] iproute2: macvlan: add "source" mode
Date: Wed, 12 Oct 2016 15:27:27 -0700
Message-ID: <20161012152727.22aab422@xeon-e3>
References: <1474830535-12689-1-git-send-email-michael-dev@fami-braun.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, projekt-wlan@fem.tu-ilmenau.de,
        steweg@gmail.com
To: Michael Braun <michael-dev@fami-braun.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:33857 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932694AbcJLWfa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 18:35:30 -0400
Received: by mail-pf0-f179.google.com with SMTP id r16so1191453pfg.1
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 15:35:30 -0700 (PDT)
In-Reply-To: <1474830535-12689-1-git-send-email-michael-dev@fami-braun.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 25 Sep 2016 21:08:55 +0200
Michael Braun <michael-dev@fami-braun.de> wrote:

> Adjusting iproute2 utility to support new macvlan link type mode called
> "source".
> 
> Example of commands that can be applied:
>   ip link add link eth0 name macvlan0 type macvlan mode source
>   ip link set link dev macvlan0 type macvlan macaddr add 00:11:11:11:11:11
>   ip link set link dev macvlan0 type macvlan macaddr del 00:11:11:11:11:11
>   ip link set link dev macvlan0 type macvlan macaddr flush
>   ip -details link show dev macvlan0
> 
> Based on previous work of Stefan Gula <steweg@gmail.com>
> 
> Signed-off-by: Michael Braun <michael-dev@fami-braun.de>
> 
> Cc: steweg@gmail.com

Applied.
