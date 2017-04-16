From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2] ip vrf: Add command name next to pid
Date: Sun, 16 Apr 2017 10:07:18 -0700
Message-ID: <20170416100718.3e094f79@xeon-e3>
References: <1492211396-18494-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36423 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756061AbdDPRH0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 16 Apr 2017 13:07:26 -0400
Received: by mail-pf0-f169.google.com with SMTP id 194so17778156pfv.3
        for <netdev@vger.kernel.org>; Sun, 16 Apr 2017 10:07:26 -0700 (PDT)
In-Reply-To: <1492211396-18494-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Apr 2017 16:09:56 -0700
David Ahern <dsa@cumulusnetworks.com> wrote:

> 'ip vrf pids' is used to list processes bound to a vrf, but it only
> shows the pid leaving a lot of work for the user. Add the command
> name to the output. With this patch you get the more user friendly:
> 
>     $ ip vrf pids mgmt
>      1121  ntpd
>      1418  gdm-session-wor
>      1488  gnome-session
>      1491  dbus-launch
>      1492  dbus-daemon
>      1565  sshd
>      ...
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Looks good, applied.
